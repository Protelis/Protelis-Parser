package org.protelis.parser.validation

import com.google.inject.Inject
import java.util.Map
import java.util.Optional
import org.eclipse.emf.common.notify.Notifier
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtext.common.types.JvmDeclaredType
import org.eclipse.xtext.common.types.JvmFeature
import org.eclipse.xtext.common.types.util.TypeReferences
import org.eclipse.xtext.validation.Check
import org.protelis.parser.protelis.Block
import org.protelis.parser.protelis.BuiltinHoodOp
import org.protelis.parser.protelis.Declaration
import org.protelis.parser.protelis.Expression
import org.protelis.parser.protelis.FunctionDef
import org.protelis.parser.protelis.GenericHood
import org.protelis.parser.protelis.Hood
import org.protelis.parser.protelis.InvocationArguments
import org.protelis.parser.protelis.JavaImport
import org.protelis.parser.protelis.Lambda
import org.protelis.parser.protelis.LongLambda
import org.protelis.parser.protelis.OldLambda
import org.protelis.parser.protelis.OldLongLambda
import org.protelis.parser.protelis.OldShortLambda
import org.protelis.parser.protelis.ProtelisModule
import org.protelis.parser.protelis.ProtelisPackage
import org.protelis.parser.protelis.ShortLambda
import org.protelis.parser.protelis.VarDef

import static extension org.protelis.parser.ProtelisExtensions.*

/**
 * Custom validation rules. 
 *
 * see http://www.eclipse.org/Xtext/documentation.html#validation
 */
class ProtelisValidator extends AbstractProtelisValidator {

	@Inject 
	TypeReferences references;

	static val Iterable<String> AUTO_IMPORT = #{ "java.lang.Math", "java.lang.Double", "org.protelis.Builtins" }

	/**
	 * Make sure that nobody defined the variable already:
	 * 
	 * other previous lets;
	 * 
	 * containing function;
	 * 
	 * containing lambda;
	 * 
	 * containing rep
	 */
	@Check
	def letNameDoesNotShadowArguments(Declaration exp) {
		var parent = exp.eContainer
		while (parent !== null) {
			if (parent instanceof Block) {
				Optional.of(parent.statements
						.takeWhile[it != exp]
						.filter[it instanceof VarDef]
						.map[it as VarDef]
						.filter[it.name == exp.name]
						.head)
					.ifPresent[error(exp)]
			}
			if (parent instanceof FunctionDef) {
				if(parent.args !== null){
					if(parent.args.args.map[it.name].contains(exp.name)){
						error(exp)
					}
				}
			}
			if (parent instanceof Lambda) {
				val Iterable<VarDef> args = switch parent {
					OldLongLambda: parent.args?.args ?: emptyList
					OldShortLambda: #[parent.singleArg]
					ShortLambda: emptyList
					LongLambda: parent.args.args
				}
				if (args.exists[it.name.equals(exp.name)]) {
					error(exp)
				}
			}
			parent = parent.eContainer
		}
	}
	
	def private error(Declaration exp)  {
		val error = "Variable " + exp.name + " has already been defined in this context. Pick another name."
		error(error, exp, null)
	}

	@Check
	def lastElementOfBlockIsExpression(Block block) {
		if (!(block.statements.last instanceof Expression)) {
			error("The last statement in a returning block must be an expression",
				block.statements.last, null
			)
		}
	}

	@Check
	def noProtelisBuiltinsAvailable(ProtelisModule module) {
		if (references.findDeclaredType("org.protelis.Builtins", module) === null) {
			warning("No builtins available. Is the interpreter in the classpath?",
				module,
				ProtelisPackage.Literals.PROTELIS_MODULE.getEStructuralFeature(ProtelisPackage.PROTELIS_MODULE__NAME)
			)
		}
	}

	@Check
	def warnOnOldLambda(OldLambda lambda) {
		val args = switch (lambda) {
			OldShortLambda: lambda.singleArg.name + " -> "
			OldLongLambda:
				if (lambda.args === null) {
					""
				} else {
					lambda.args.args.join("", ", ", " -> ")[it.name]
				}
		}
		warning('''This lambda could be rewritten as { «args»<body> }''', null)
	}

	@Check
	def deprecatedHoodOperation(BuiltinHoodOp hood) {
		deprecatedHoodOperation(hood, ProtelisPackage.Literals.BUILTIN_HOOD_OP.getEStructuralFeature(ProtelisPackage.BUILTIN_HOOD_OP__NAME))
	}

	@Check
	def deprecatedHoodOperation(GenericHood hood) {
		deprecatedHoodOperation(hood, ProtelisPackage.Literals.HOOD.getEStructuralFeature(ProtelisPackage.HOOD__NAME))
	}

	def deprecatedHoodOperation(Hood hood, EStructuralFeature feature) {
		warning("Hardcoded hood operations have been deprecated and will be removed in a future release, see https://github.com/Protelis/Protelis/issues/75",
			hood,
			feature
		)
	}

	@Check
	def emptyStarImport(JavaImport javaImport) {
		if (javaImport.isWildcard && javaImport.importedType.callableEntities.isEmpty) {
			warning('''No callable members in «javaImport.importedType.simpleName»''', ProtelisPackage.Literals.JAVA_IMPORT__IMPORTED_TYPE)
		}
	}

	@Check
	def unresolvableMethodOrField(JavaImport javaImport) {
		if (!javaImport.isWildcard && javaImport.importedType.callableEntitiesNamed(javaImport.importedMemberName).isEmpty) {
			error(
				'''«javaImport.importedMemberName» is not a callable member of «javaImport.importedType.simpleName»''',
				ProtelisPackage.Literals.JAVA_IMPORT__IMPORTED_MEMBER_NAME
			)
		}
	}

	def private autoImports(Notifier context) {
		AUTO_IMPORT
			.map[references.findDeclaredType(it, context) as JvmDeclaredType]
			.flatMap[allFeatures]
	}

	@Check
	def importOfAutomaticallyImportedClass(JavaImport javaImport) {
		val shadow = javaImport.shadows
		if (!shadow.isEmpty) {
			shadow.forEach [ manual, auto|
				info('''«manual.qualifiedName» shadows automatically imported «auto.qualifiedName»''',
					ProtelisPackage.Literals.JAVA_IMPORT__IMPORTED_TYPE
				)
			]
		}
	}

	def private Map<JvmFeature, JvmFeature> shadows(JavaImport javaImport) {
		val automaticallyImported = autoImports(javaImport)
		val shade = newLinkedHashMap
		javaImport.importedEntities.forEach[ manual |
			val shadowed = automaticallyImported.findFirst[simpleName == manual.simpleName]
			if (shadowed !== null) {
				shade.put(manual, shadowed)
			}
		]
		shade
	}

	@Check
	def invokeLambdaWithCorrectNumberOfArguments(Expression invoke) {
		if (invoke.name === null
			&& invoke.elements.size == 2
			&& invoke.elements.get(0) instanceof Lambda
			&& invoke.elements.get(1) instanceof InvocationArguments
		) {
			val Lambda left = invoke.elements.get(0) as Lambda
			val InvocationArguments args = invoke.elements.get(1) as InvocationArguments
			val provided = (if (args === null || args.args === null) 0 else args.args.args.size) + 
				if (args.lastArg === null) 0 else 1
			val matches = switch (left) {
				OldShortLambda: provided == 1
				OldLongLambda: if (left.args === null ) provided == 0 else left.args.args.size == provided
				ShortLambda: provided == 0 || provided == 1
				LongLambda: left.args.args.size == provided
			}
			if (!matches) {
				error("Arguments provided for invocation do not match lambda parameters", invoke, null)
			}
		} 
	}

}
