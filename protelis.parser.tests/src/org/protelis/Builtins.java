package org.protelis;

import org.protelis.parser.validation.ProtelisValidator;

import com.google.common.collect.ImmutableList;

/**
 * This class emulates the builtins that must be provided by the interpreter.
 */
public class Builtins {

	/**
	 * This variable is used by the interpreter for providing compatibility hints in
	 * the Eclipse plugin. See https://github.com/Protelis/Protelis/issues/245.
	 */
	public static final ImmutableList<Integer> MINIMUM_PARSER_VERSION = ProtelisValidator.MY_VERSION;
	/**
	 * This variable is used by the interpreter for providing compatibility hints in
	 * the Eclipse plugin. See https://github.com/Protelis/Protelis/issues/245.
	 */
	public static final ImmutableList<Integer> MAXIMUM_PARSER_VERSION = ProtelisValidator.MY_VERSION;

}
