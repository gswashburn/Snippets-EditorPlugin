extends Node

# I want to add special kinds of fields in snippets that get
# expanded to user-specified values in the editor. Functionally, they
# are smilar to String's format method. The issue is, the fields need to be
# something that cannot be compiled by Godot and uses none of its syntax,
# lest pieces of code get misinterpreted as fields. For that reason, curly braces
# cannot be used.

# This functionality will be invoked when copying a snippet to the clipboard; it
# will happen right before the clipboard is modified.

# Now, let's use something like this: %FIELDNAME:title%. This defines a field
# with the speciied name and gives it a string to display in the editor when
# prompting the user for a value. Subsequent references to the same field will
# be substituted with the value.

### Test

#func get_%PROPERTY:Property%():
#	return %PROPERTY%

#func set_%PROPERTY:Property%(value: %TYPE:Type%) -> void:
#	%PROPERTY% = value

###
