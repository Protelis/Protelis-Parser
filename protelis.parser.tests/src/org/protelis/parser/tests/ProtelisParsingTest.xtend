package org.protelis.parser.tests

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith
import org.protelis.parser.protelis.ProtelisModule

import static org.junit.Assert.assertFalse
import static org.junit.Assert.assertNotNull
import static org.junit.Assert.assertTrue

@ExtendWith(InjectionExtension)
@InjectWith(ProtelisInjectorProvider)
class ProtelisParsingTest {
	@Inject	extension ParseHelper<ProtelisModule> parseHelper
	@Inject	extension ValidationTestHelper validationHelper
	
	def ProtelisModule shouldParseCorrectly(CharSequence program) {
		assertNotNull(program)
		val result = program.parse
		assertNotNull('''Could not initialize «program»''', result)
		assertNotNull(result.eResource)
		assertNotNull(result.eResource.errors)
		assertTrue('''Unexpected Parsing errors:\n«result.eResource.errors.join("\n")»''', result.eResource.errors.isEmpty)
		result
	}

	def validate(CharSequence program) {
		val result = program.shouldParseCorrectly.validate
		assertNotNull(result)
		result
	}

	def void shouldBeValid(CharSequence program) {
		val result = program.validate
		assertTrue('''Unexpected validation errors:\n«result.join("\n")»''', result.isEmpty)
	}

	def void shouldNotBeValid(CharSequence program) {
		val result = program.validate
		assertFalse('''Errors expected, but parsing and validation competed successfully for\n«program»''', result.isEmpty)
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
		[5, 4, 3, 2, 1].reduce(self, Infinity, (a, b) -> {
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

}
