package org.protelis.parser.tests

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.junit.jupiter.api.Test
import static org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.^extension.ExtendWith
import org.protelis.parser.protelis.ProtelisModule
import java.util.List
import org.eclipse.emf.mwe.core.issues.Issues
import org.eclipse.xtext.validation.Issue
import org.eclipse.xtext.diagnostics.Severity
import static org.eclipse.xtext.diagnostics.Severity.*

@ExtendWith(InjectionExtension)
@InjectWith(ProtelisInjectorProvider)
class ProtelisParsingTest {
	@Inject	extension ParseHelper<ProtelisModule> parseHelper
	@Inject	extension ValidationTestHelper validationHelper
	
	def ProtelisModule tryToParse(CharSequence program) {
		assertNotNull(program)
		val result = program.parse
		assertNotNull(result, [ '''Could not initialize «program»''' ])
		assertNotNull(result.eResource)
		assertNotNull(result.eResource.errors)
		result
	}
	
	def shouldParseCorrectly(ProtelisModule program) {
		assertTrue(program.eResource.errors.isEmpty, [ '''Unexpected Parsing errors:\n«program.eResource.errors.join("\n")»''' ])
	}

	def hasInvalidSyntax(ProtelisModule program) {
		assertFalse(program.eResource.errors.isEmpty, [ "Parsing errors expected, none found"])
	}

	def void mustRaise(ProtelisModule program, Severity issueType) {
		assertFalse(program.raised(issueType).isEmpty) [
			'''Errors expected, but parsing and validation competed successfully for\n«program»'''
		]
	}

	def void mustNotRaise(ProtelisModule program, Severity issueType) {
		val errors = program.raised(issueType)
		assertTrue(errors.isEmpty) [
			'''Unexpected validation errors:\n«errors.join("\n")»'''
		]
	}

	def Iterable<Issue> raised(ProtelisModule program, Severity issueType) {
		program.validate.filter[it.severity == issueType]
	}

	def Iterable<Issue> errors(ProtelisModule program) { program.raised(ERROR) }

	def Iterable<Issue> warnings(ProtelisModule program) { program.raised(WARNING) }

	def void whenParsed(CharSequence prog, (ProtelisModule)=>void todos) {
		todos.apply(prog.tryToParse)
	}

	@Test
	def void loadModel() {
		'''
		// Single line comment
		/*
		Multiline comment
		*/
		module test
		minHood(nbr(1))
		'''.whenParsed [
			shouldParseCorrectly
			mustNotRaise(ERROR)
			mustRaise(WARNING)
		]
	}

	@Test
	def void testParseTupleReduce01() {
		'''
		// EXPECTED_RESULT: 1
		import java.lang.Double.POSITIVE_INFINITY
		[5, 4, 3, 2, 1].reduce(self, POSITIVE_INFINITY, (a, b) -> {
			if(a < b) {
				a
			} else {
				b
			}
		})
		'''.whenParsed [
			mustNotRaise(ERROR)
			mustRaise(WARNING)
		]
	}

	@Test
	def void simpleTuplesCanBeParsed() {
		'''
		[5, 4, 3, 2, 1]
		'''.whenParsed [
			mustNotRaise(ERROR)
			mustNotRaise(WARNING)
		]
	}

	@Test
	def void methodsCanBeInvokedOnTuple() {
		'''
		[5, 4, 3, 2, 1].reduce()
		'''.whenParsed [
			mustNotRaise(ERROR)
			mustNotRaise(WARNING)
		]
	}

	@Test
	def void testJavaParse() {
		'''
		// EXPECTED_RESULT: 0
		import java.lang.Math.sin
		java::lang::Math::sin(0)
		'''.whenParsed [
			mustNotRaise(ERROR)
		]
	}

	@Test
	def void testJavaParseStar() {
		'''
		import java.lang.Math.*
		java::lang::Math::sin(0)
		'''.whenParsed [ 
			mustNotRaise(ERROR)
		]
	}

	@Test
	def void testParseShare() {
		'''
		share (x, y <- 0) { x + 1 }
		'''.whenParsed [ mustNotRaise(ERROR)]
	}

	@Test
	def void testImportsInAnyOrder() {
		'''
		import protelis:lang:state
		import java.lang.Math.sin
		import protelis:lang:coord
		import java.lang.Math.cos
		import protelis:lang:meta
		1
		'''.whenParsed [
			shouldParseCorrectly
		]
	}

	@Test
	def void testJavaStaticField() {
		'''
		import java.lang.Math.PI
		PI
		'''.whenParsed [ mustNotRaise(ERROR) ]
	}

	@Test
	def void testJavaStaticFieldWithStarImport() {
		'''
		import java.lang.Integer.*
		MAX_VALUE
		'''.whenParsed [ mustNotRaise(ERROR) ]
	}

	@Test
	def void letCanBeParsed() {
		'''
		let x = 1
		1
		'''.whenParsed [
			mustNotRaise(WARNING)
			mustNotRaise(ERROR)
		]
	}

	@Test
	def void testInvalidReferenceWithStarImport() {
		'''
		import java.lang.Integer.*
		POSITIVE_INFINITY
		'''.whenParsed [ mustNotRaise(ERROR) ]
	}

	@Test
	def void testJavaResolveFailure() {
		'''
		// EXPECTED_RESULT: 0
		import java.lang.Math.sinsdsadasdsa
		java::lang::Math::sin(0)
		'''.whenParsed [
			shouldParseCorrectly
			mustRaise(ERROR)
		]
	}

	@Test
	def void testMultilineBlock() {
		'''
		1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 
		1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 
		1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 
		1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 
		1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 
		1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 
		1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 
		1
		'''.whenParsed [
			mustNotRaise(ERROR)
			mustNotRaise(WARNING)
		]
	}

	@Test
	def void testMultiInstructionWithoutSemicolonBlock() {
		'''
		1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
		1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
		1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
		1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
		1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
		1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
		'''.whenParsed [
			mustNotRaise(ERROR)
			mustNotRaise(WARNING)
		]
	}

	@Test
	def void testKotlinItRename() {
		'''
		{ a -> a + 1 }
		'''.whenParsed [
			mustNotRaise(ERROR)
			mustNotRaise(WARNING)
		]

	}

	@Test
	def void lambdaShouldBeInvokable() {
		'''
		{ a -> a + 1 }(1)
		'''.whenParsed [
			mustNotRaise(ERROR)
			mustNotRaise(WARNING)
		]

	}

	@Test
	def void lambdaInvocationWithBadArgumentsShouldFail() {
		'''
		{ a -> a + 1 }()
		'''.whenParsed [
			mustRaise(ERROR)
		]

	}

	@Test
	def void parameterAccessShouldBeAllowed() {
		'''
		public def identity(a) {
			a
		}
		'''.whenParsed [
			mustNotRaise(ERROR)
			mustNotRaise(WARNING)
		]

	}

	@Test
	def void testKotlinStyleLambda() {
		'''
		{ it + 1 }
		'''.whenParsed [
			mustNotRaise(ERROR)
			mustNotRaise(WARNING)
		]
		'''
		{ it -> it + 1 }
		'''.whenParsed [
			mustRaise(ERROR)
		]
		'''
		def f(a) {
			a
		}
		f({ it + 1 })
		'''.whenParsed [
			mustNotRaise(ERROR)
			mustNotRaise(WARNING)
		]
		'''
		def f(a) {
			a
		}
		f{ it + 1 }
		'''.whenParsed [
			mustNotRaise(ERROR)
			mustNotRaise(WARNING)
		]
		'''
		def f(a) {
			a
		}
		f(){ it + 1 }
		'''.whenParsed [
			mustNotRaise(ERROR)
			mustNotRaise(WARNING)
		]
	}

	@Test
	def void testAutoImport() {
		'''
		sin(0)
		'''.whenParsed [
			mustNotRaise(WARNING)
			mustNotRaise(ERROR)
		]
	}

	@Test
	def void ifWithoutParenthesisShouldResolveVariables() {
		'''
		let foo = true;
		if (foo) { 1 };
		2
		'''.whenParsed [ mustNotRaise(ERROR) ]
	}

	@Test
	def void testIfWithoutParentheses() {
		'''
		let x = if (1 < 3) { 1 };
		1
		'''.whenParsed [ hasInvalidSyntax ]
		'''
		let foo = true;
		if (foo) { 1 }
		'''.whenParsed [ mustRaise(ERROR) ]
		'''
		if (1 < 3) { 1 }
		'''.whenParsed [ mustRaise(ERROR) ]
		''' // Jake's example from https://github.com/Protelis/Protelis/issues/65
		let y = if (false) { 3 };
		y+1;
		'''.whenParsed [ hasInvalidSyntax ]
		'''
		if (1 < 3) { 1 } else { 2 }
		'''.whenParsed [ mustNotRaise(ERROR) ]
		'''
		if (1 < 3) { 1 };
		if (1 < 3) { 1 } else { 2 }
		'''.whenParsed [ mustNotRaise(ERROR) ]
		'''
		let x = if (1 < 3) { 1 } else { 2 };
		1
		'''.whenParsed [ mustNotRaise(ERROR) ]
		'''
		let a = 0;
		if (true) { a = a + 1 }; // Pure side effect
		a
		'''.whenParsed [ mustNotRaise(ERROR) ]
		'''
		def myfun() {
			let a = 0;
			if (true) { a = a + 1 }; // Pure side effect
			a
		}
		myfun()
		'''.whenParsed [ mustNotRaise(ERROR) ]
		'''
		// EXPECTED_RESULT: 256
		let x = 2; // 2
		x = x * x; // 4 
		x = x ^ x; // 256
		x
		'''.whenParsed [ mustNotRaise(ERROR) ]
		'''
		// EXPECTED_RESULT: 2
		let x = 0;
		if(false) {
			x = 1;
			x
		} else {
			x = 2;
			x
		}'''.whenParsed [ mustNotRaise(ERROR) ]
	}

}
