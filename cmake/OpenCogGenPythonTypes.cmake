#
# OpenCogGenPythonTypes.cmake
#
# Definitions for automatically building a Python `atom_types.pyx`
# file, given a master file `atom_types.script`.
#
# Example usage:
# OPENCOG_PYTHON_ATOMTYPES(atom_types.script core_types.pyx)
#
# ===================================================================

MACRO(OPENCOG_PYTHON_SETUP SCRIPT_FILE PYTHON_FILE)
	SET(PYTHON_SUPPORTED_VALUE_LIST)

	IF (NOT PYTHON_FILE)
		MESSAGE(FATAL_ERROR "OPENCOG_PYTHON_ATOMTYPES missing PYTHON_FILE")
	ENDIF (NOT PYTHON_FILE)

	MESSAGE(DEBUG "Generating Python Atom Type defintions from ${SCRIPT_FILE}.")

	FILE(WRITE "${PYTHON_FILE}"
		"\n"
		"# DO NOT EDIT THIS FILE! This file was automatically generated from atom\n"
		"# definitions in types.script by the macro OPENCOG_ADD_ATOM_TYPES\n"
		"#\n"
		"# This file contains basic python wrappers for atom creation.\n"
		"#\n"
		"\n"
	)
ENDMACRO()

# ------------
# Print out the python definitions. Note: We special-case Atom
# since we don't want to create a function with the same
# identifier as the Python Atom object.
MACRO(OPENCOG_PYTHON_WRITE_DEFS PYTHON_FILE)
	IF (NOT TYPE_NAME STREQUAL "Atom")
		IF (ISVALUE STREQUAL "VALUE" OR ISSTREAM STREQUAL "STREAM")
			LIST(FIND PYTHON_SUPPORTED_VALUE_LIST ${TYPE_NAME} _INDEX)
			IF (${_INDEX} GREATER -1)
				# Single arg will work as all of value constructors has
				# single argument: either value or vector.
				FILE(APPEND "${PYTHON_FILE}"
					"def ${TYPE_NAME}(arg):\n"
					"    return createValue(types.${TYPE_NAME}, arg)\n"
				)
			ENDIF (${_INDEX} GREATER -1)
		ENDIF (ISVALUE STREQUAL "VALUE" OR ISSTREAM STREQUAL "STREAM")
		IF (ISNODE STREQUAL "NODE")
			FILE(APPEND "${PYTHON_FILE}"
				"def ${TYPE_NAME}(node_name, tv=None):\n"
				"    return add_node(types.${TYPE_NAME}, node_name, tv)\n"
			)
		ENDIF (ISNODE STREQUAL "NODE")
		IF (ISLINK STREQUAL "LINK")
			FILE(APPEND "${PYTHON_FILE}"
				"def ${TYPE_NAME}(*args, tv=None):\n"
				"    return add_link(types.${TYPE_NAME}, args, tv=tv)\n"
			)
		ENDIF (ISLINK STREQUAL "LINK")
	ENDIF (NOT TYPE_NAME STREQUAL "Atom")

	# If not named as a node or a link, assume its a link
	# This is kind of hacky, but I don't know what else to do ...
	IF (NOT ISATOMSPACE STREQUAL "ATOMSPACE" AND
		NOT ISNODE STREQUAL "NODE" AND
		NOT ISLINK STREQUAL "LINK" AND
		NOT ISVALUE STREQUAL "VALUE" AND
		NOT ISSTREAM STREQUAL "STREAM")
		FILE(APPEND "${PYTHON_FILE}"
			"def ${TYPE_NAME}(*args):\n"
			"    return add_link(types.${TYPE_NAME}, args)\n"
		)
	ENDIF (NOT ISATOMSPACE STREQUAL "ATOMSPACE" AND
		NOT ISNODE STREQUAL "NODE" AND
		NOT ISLINK STREQUAL "LINK" AND
		NOT ISVALUE STREQUAL "VALUE" AND
		NOT ISSTREAM STREQUAL "STREAM")
ENDMACRO(OPENCOG_PYTHON_WRITE_DEFS PYTHON_FILE)

# ------------
# Main entry point.
MACRO(OPENCOG_PYTHON_ATOMTYPES SCRIPT_FILE PYTHON_FILE)

	OPENCOG_PYTHON_SETUP(${SCRIPT_FILE} ${PYTHON_FILE})
	FILE(STRINGS "${SCRIPT_FILE}" TYPE_SCRIPT_CONTENTS)
	FOREACH (LINE ${TYPE_SCRIPT_CONTENTS})
		OPENCOG_TYPEINFO_REGEX()
		IF (MATCHED AND CMAKE_MATCH_1)

			OPENCOG_TYPEINFO_SETUP()
			OPENCOG_PYTHON_WRITE_DEFS(${PYTHON_FILE})    # Print out the scheme definitions
		ELSEIF (NOT MATCHED)
			MESSAGE(FATAL_ERROR "Invalid line in ${SCRIPT_FILE} file: [${LINE}]")
		ENDIF ()
	ENDFOREACH (LINE)

ENDMACRO()

#####################################################################
