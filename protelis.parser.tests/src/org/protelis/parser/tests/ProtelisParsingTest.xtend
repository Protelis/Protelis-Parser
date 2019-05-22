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
	
	def ProtelisModule shouldParseCorrectly(CharSequence program) {
		val result = program.tryToParse
		assertTrue(result.eResource.errors.isEmpty, [ '''Unexpected Parsing errors:\n«result.eResource.errors.join("\n")»''' ])
		result
	}

	def shouldNotParse(CharSequence program) {
		assertFalse(tryToParse(program).eResource.errors.isEmpty, [ "Parsing errors expected, none found"])
	}

	def validate(CharSequence program) {
		val result = program.shouldParseCorrectly.validate
		assertNotNull(result)
		result
	}

	def void shouldBeValid(CharSequence program) {
		val result = program.validate
		assertTrue(result.isEmpty, ['''Unexpected validation errors:\n«result.join("\n")»'''])
	}

	def void shouldNotBeValid(CharSequence program) {
		val result = program.validate
		assertFalse(result.isEmpty, [ '''Errors expected, but parsing and validation competed successfully for\n«program»''' ])
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
		'''.shouldBeValid
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
		'''.shouldBeValid
	}

	@Test
	def void testJavaParse() {
		'''
		// EXPECTED_RESULT: 0
		import java.lang.Math.sin
		java::lang::Math::sin(0)
		'''.shouldBeValid
	}

	@Test
	def void testJavaParseStar() {
		'''
		import java.lang.Math.*
		java::lang::Math::sin(0)
		'''.shouldBeValid
	}

	@Test
	def void testParseShare() {
		'''
		share (x, y <- 0) { x + 1 }
		'''.shouldBeValid
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
		'''.shouldParseCorrectly
	}

	@Test
	def void testJavaStaticField() {
		'''
		import java.lang.Math.PI
		PI
		'''.shouldBeValid
	}

	@Test
	def void testJavaStaticFieldWithStarImport() {
		'''
		import java.lang.Integer.*
		MAX_VALUE
		'''.shouldBeValid
	}

	@Test
	def void testInvalidReferenceWithStarImport() {
		'''
		import java.lang.Integer.*
		POSITIVE_INFINITY
		'''.shouldNotBeValid
	}

	@Test
	def void testJavaResolveFailure() {
		'''
		// EXPECTED_RESULT: 0
		import java.lang.Math.sinsdsadasdsa
		java::lang::Math::sin(0)
		'''
		.shouldNotBeValid
	}

	@Test
	def void testIfWithoutParentheses() {
		'''
		let x = if (1 < 3) { 1 };
		1
		'''.shouldNotParse
		'''
		let foo = true;
		if (foo) { 1 }
		'''.shouldNotParse
		'''
		if (1 < 3) { 1 }
		'''.shouldNotParse
		''' // Jake's example from https://github.com/Protelis/Protelis/issues/65
		let y = if (false) { 3 };
		y+1;
		'''.shouldNotParse
		'''
		if (1 < 3) { 1 } else { 2 }
		'''.shouldBeValid
		'''
		if (1 < 3) { 1 };
		if (1 < 3) { 1 } else { 2 }
		'''.shouldBeValid
		'''
		let x = if (1 < 3) { 1 } else { 2 };
		1
		'''.shouldBeValid
		'''
		let foo = true;
		if (foo) { 1 };
		2
		'''.shouldBeValid
	}

}
