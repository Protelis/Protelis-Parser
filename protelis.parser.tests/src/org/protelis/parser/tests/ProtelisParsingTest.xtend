package org.protelis.parser.tests

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.junit.jupiter.api.Assertions
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith
import org.protelis.parser.protelis.ProtelisModule

@ExtendWith(InjectionExtension)
@InjectWith(ProtelisInjectorProvider)
class ProtelisParsingTest {
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
		Assertions.assertNotNull(result)
		val errors = result.eResource.errors
		Assertions.assertTrue(errors.isEmpty, '''Unexpected errors: «errors.join(", ")»''')
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
		Assertions.assertNotNull(result)
		val errors = result.eResource.errors
		Assertions.assertTrue(errors.isEmpty, '''Unexpected errors: «errors.join(", ")»''')
	}

	@Test
	def void testJavaParse() {
		val result = parseHelper.parse('''
// EXPECTED_RESULT: 0
import java.lang.Math.sin
java::lang::Math::sin(0)
		''')
		Assertions.assertNotNull(result)
		val errors = result.eResource.errors
		Assertions.assertTrue(errors.isEmpty, '''Unexpected errors: «errors.join(", ")»''')
	}

	@Test
	def void testParseShare() {
		val result = parseHelper.parse('''
share (x, y <- 0) { x + 1 }
		''')
		Assertions.assertNotNull(result)
		val errors = result.eResource.errors
		Assertions.assertTrue(errors.isEmpty, '''Unexpected errors: «errors.join(", ")»''')
	}

}
