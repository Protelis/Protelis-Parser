package org.protelis.parser.tests

import com.google.inject.Inject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import org.protelis.parser.protelis.ProtelisModule

@RunWith(XtextRunner)
@InjectWith(ProtelisInjectorProvider)
class ProtelisParsingTest{

	@Inject
	ParseHelper<ProtelisModule> parseHelper

	@Test 
	def void loadModel() {
		val result = parseHelper.parse('''
			// Single line comment
			/*
			Multiline comment
			*/
			module test
			minHood(nbr(1))
		''')
		Assert.assertNotNull(result)
		val errors = result.eResource.errors
		Assert.assertTrue('''Unexpected errors: «errors.join(", ")»''', errors.isEmpty)
	}
	
	@Test
	def void testParseTupleReduce01() {
		val result = parseHelper.parse('''
// EXPECTED_RESULT: 1
[5, 4, 3, 2, 1].reduce(self, Infinity, (a, b) -> {
	if(a < b) {
		a
	} else {
		b
	}
})
		''')
		Assert.assertNotNull(result)
		val errors = result.eResource.errors
		Assert.assertTrue('''Unexpected errors: «errors.join(", ")»''', errors.isEmpty)
	}

	@Test
	def void testJavaParse() {
		val result = parseHelper.parse('''
// EXPECTED_RESULT: 0
import java.lang.Math.sin
java::lang::Math::sin(0)
		''')
		Assert.assertNotNull(result)
		val errors = result.eResource.errors
		Assert.assertTrue('''Unexpected errors: «errors.join(", ")»''', errors.isEmpty)
	}

	@Test
	def void testParseShare() {
		val result = parseHelper.parse('''
share (x, y <- 0) { x + 1 }
		''')
		Assert.assertNotNull(result)
		val errors = result.eResource.errors
		Assert.assertTrue('''Unexpected errors: «errors.join(", ")»''', errors.isEmpty)
	}

}
