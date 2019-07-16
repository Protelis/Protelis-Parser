package org.protelis.parser

import org.eclipse.xtext.common.types.JvmDeclaredType
import org.eclipse.xtext.common.types.JvmFeature
import org.eclipse.xtext.common.types.JvmField
import org.eclipse.xtext.common.types.JvmOperation
import org.eclipse.xtext.common.types.JvmType
import org.eclipse.xtext.common.types.JvmVisibility
import java.util.Objects
import org.protelis.parser.protelis.JavaImport

class ProtelisExtensions {

	def static Iterable<JvmFeature> callableEntities(JvmDeclaredType type) {
		type?.allFeatures?.filter[it.isCallable] ?: emptyList
	}

	def static Iterable<JvmFeature> callableEntities(JvmType type) {
		if (type instanceof JvmDeclaredType) type.callableEntities else emptyList
	}

	def static Iterable<JvmFeature> importedEntities(JavaImport imported) {
		(imported.isWildcard
			? imported.importedType.allFeatures
			: imported.importedType.findAllFeaturesByName(imported.importedMemberName)
		).filter[isCallable]
	}

	def static Iterable<JvmFeature> callableEntitiesNamed(JvmDeclaredType type, CharSequence name) {
		type?.findAllFeaturesByName(Objects.requireNonNull(name, "name can't be null").toString)
			?.filter[isCallable]
			?: emptyList
	}

	def static boolean isCallable(JvmFeature feature) {
		(feature instanceof JvmField || feature instanceof JvmOperation)
		&& feature.isStatic
		&& feature.visibility == JvmVisibility.PUBLIC
	}
}