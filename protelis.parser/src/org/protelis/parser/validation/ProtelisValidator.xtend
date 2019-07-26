package org.protelis.parser.validation

import com.google.inject.Inject
import java.util.Map
import org.eclipse.emf.common.notify.Notifier
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtext.common.types.JvmDeclaredType
import org.eclipse.xtext.common.types.JvmFeature
import org.eclipse.xtext.common.types.util.TypeReferences
import org.eclipse.xtext.validation.Check
import org.protelis.parser.protelis.Block
import org.protelis.parser.protelis.BuiltinHoodOp
import org.protelis.parser.protelis.FunctionDef
import org.protelis.parser.protelis.GenericHood
import org.protelis.parser.protelis.Hood
import org.protelis.parser.protelis.JavaImport
import org.protelis.parser.protelis.Lambda
import org.protelis.parser.protelis.ProtelisModule
import org.protelis.parser.protelis.ProtelisPackage
import org.protelis.parser.protelis.VarDef
import org.protelis.parser.protelis.VarDefList

import static extension org.protelis.parser.ProtelisExtensions.*
import org.protelis.parser.protelis.Expression
import java.util.Optional
import org.protelis.parser.protelis.OldLambda
import org.protelis.parser.protelis.Declaration
import org.protelis.parser.protelis.AnyLambda

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
			if (parent instanceof AnyLambda) {
				if(parent.args !== null) {
					val args = parent.args;
					if(args instanceof VarDef){
						if (args.name.equals(exp.name)) {
							error(exp)
						}
					} else if (args instanceof VarDefList) {
						if (args.args.map[it.name].contains(exp.name)) {
							error(exp)
						}
					}
				}
			}
			parent = parent.eContainer
		}
	}
	
	def error(Declaration exp)  {
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

	def autoImports(Notifier context) {
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

	def Map<JvmFeature, JvmFeature> shadows(JavaImport javaImport) {
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

}
