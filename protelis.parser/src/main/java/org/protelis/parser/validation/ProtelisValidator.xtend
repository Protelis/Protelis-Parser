package org.protelis.parser.validation

import com.google.common.collect.ImmutableList
import com.google.inject.Inject
import java.lang.reflect.Field
import java.lang.reflect.Modifier
import java.util.List
import java.util.Map
import java.util.Optional
import org.eclipse.emf.common.notify.Notifier
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtext.common.types.JvmDeclaredType
import org.eclipse.xtext.common.types.JvmFeature
import org.eclipse.xtext.common.types.util.TypeReferences
import org.eclipse.xtext.validation.Check
import org.protelis.parser.protelis.Assignment
import org.protelis.parser.protelis.Block
import org.protelis.parser.protelis.BuiltinHoodOp
import org.protelis.parser.protelis.Declaration
import org.protelis.parser.protelis.Expression
import org.protelis.parser.protelis.FunctionDef
import org.protelis.parser.protelis.GenericHood
import org.protelis.parser.protelis.Hood
import org.protelis.parser.protelis.InvocationArguments
import org.protelis.parser.protelis.It
import org.protelis.parser.protelis.JavaImport
import org.protelis.parser.protelis.Lambda
import org.protelis.parser.protelis.LongLambda
import org.protelis.parser.protelis.MethodCall
import org.protelis.parser.protelis.OldLambda
import org.protelis.parser.protelis.OldLongLambda
import org.protelis.parser.protelis.OldShortLambda
import org.protelis.parser.protelis.ProtelisModule
import org.protelis.parser.protelis.ProtelisPackage
import org.protelis.parser.protelis.ShortLambda
import org.protelis.parser.protelis.VarDef

import static extension org.protelis.parser.ProtelisExtensions.*
import org.eclipse.xtext.xbase.interpreter.IEvaluationContext
import org.eclipse.xtext.naming.IQualifiedNameConverter

/**
 * Custom validation rules. 
 *
 * see http://www.eclipse.org/Xtext/documentation.html#validation
 */
class ProtelisValidator extends AbstractProtelisValidator {

	public static val MY_VERSION = ImmutableList.of(10, 0, 2)
	static val FIRST_LINE = ProtelisPackage.Literals.PROTELIS_MODULE.getEStructuralFeature(ProtelisPackage.PROTELIS_MODULE__NAME)

	@Inject 
	TypeReferences references
	@Inject
	IEvaluationContext context
	@Inject
	IQualifiedNameConverter qualifiedNameConverter

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
				Optional.ofNullable(parent.statements
						.takeWhile[it != exp]
						.map[it instanceof Declaration ? it.name : it]
						.filter[it instanceof VarDef]
						.map[it as VarDef]
						.filter[it.name == exp.name.name]
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
		if (!(block.statements.lastOrNull instanceof Expression)) {
			error("The last statement in a returning block must be an expression",
				block.statements.lastOrNull, null
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

	private def error(String message, EObject target) {
		error(message, target, null)
	}

	private def warning(String message, EObject target) {
		warning(message, target, null)
	}

	@Check
	def discourageDotApply(Expression methodCall) {
		if (methodCall.name == '.') {
			val call = methodCall.elements.get(1) as MethodCall
			if(call.name == 'apply') {
				warning('''<invokable>.apply(...) is discouraged, prefer direct invocation: <invokable>(...)''', call)
			}
		}
	}

	@Check
	def reassignIsBadPractice(Assignment assignment) {
		warning('''Reassigning variables such as «assignment.refVar.name» is discouraged and may be dropped in a future release of Protelis. Prefer a functional approach.''', assignment)
	}

	@Check
	def uselessModule(ProtelisModule module) {
		if (module.program === null) {
			if (module.definitions === null
				|| module.definitions.findFirst[it.public] === null
			)
			warning('''Module «module.name ?: "anonymous"» is useless, it does not contain a program nor a public function''', module)
		}
	}

	@Check
	def appropriateUseOfIt(It it) {
		// Valid iff exactly one parent is a shortlambda
		var shortLambdaParents = 0
		for (var parent = it.eContainer; shortLambdaParents < 2 && parent !== null; parent = parent.eContainer) {
			shortLambdaParents += parent instanceof ShortLambda ? 1 : 0
		}
		switch(shortLambdaParents) {
			case 0: error("it can only be used inside short lambdas (i.e. { it + 1 })", it)
			case 2: error("Ambiguous use of it due to nested short lambdas: refactor with explicit names, e.g. rewrite { it + 1 } as { a -> a + 1 }", it)
		}
	}

	@Check
	def functionCouldBeRewrittenAsSingleExpression(FunctionDef function) {
		if (function.body !== null && function.body.statements.size == 1) {
			val name = function.name
			info('''«name» (<params>) { <body> } has a single expression and could be rewritten as «name» (<params>) = <body>''', function.body.statements.get(0), null)
		}
	}

	/**
	 * See https://github.com/Protelis/Protelis/issues/245
	 */
	@Check
	def builtinVersionShouldBeCompatible(ProtelisModule module) {
		val type = references.findDeclaredType("org.protelis.Builtins", module)
		if (type instanceof JvmDeclaredType) {
			val builtinsResolvedClass = context.getValue(qualifiedNameConverter.toQualifiedName("org.protelis.Builtins")) as Class<?>
			val candidateFields = builtinsResolvedClass.declaredFields
			val min = candidateFields.findFirst[it.name == "MINIMUM_PARSER_VERSION"]
			var minVersion = versionFromStaticField(min)
			if (minVersion === null) {
				warning(
					"Builtins do not declare a minimum version, Protelis plugin / parser and interpreter versions may be mismatched",
					module, FIRST_LINE
				)
			}
			minVersion = minVersion ?: #[0, 0, 0]
			val max = candidateFields.findFirst[it.name == "MAXIMUM_PARSER_VERSION"]
			var maxVersion = versionFromStaticField(max)
			if (maxVersion === null) {
				warning("Builtins do not declare a maximum version", module, FIRST_LINE)
			}
			maxVersion = maxVersion ?: #[Integer.MAX_VALUE, Integer.MAX_VALUE, Integer.MAX_VALUE]
			if (!(versionMinorEqual(MY_VERSION, maxVersion) && versionMinorEqual(minVersion, MY_VERSION))) {
				warning(
					'''Protelis plugin / parser and interpreter versions mismatch. Expected parser in range «minVersion» to «maxVersion», found version «MY_VERSION»'''
					, module, FIRST_LINE
				)
			}
		}
	}

	private def List<Integer> versionFromStaticField(Field field) {
		if (field === null) {
			return null
		} else {
			if (Modifier.isStatic(field.modifiers)
				&& typeof(List).isAssignableFrom(field.type)
			) {
				val fieldValue = field.get(null) as List<?>
				if (fieldValue.size == 3 && fieldValue.forall[Integer.isAssignableFrom(it.class)]) {
					return fieldValue as List<Integer>
				}
			}
		}
		return null
	}

	private def boolean versionMinorEqual(Iterable<Integer> a, Iterable<Integer> b) {
		a.empty && b.empty
		|| a.head < b.head
		|| a.head == b.head && versionMinorEqual(a.drop(1), b.drop(1))
	}

}
