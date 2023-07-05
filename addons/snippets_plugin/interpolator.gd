extends Reference

const FIELDDEF_REGEX := '%(\\w+):(\\w+)%'
const FIELD_REGEX := '%(\\w+)(:\\w+)?%'

var code := ""

func _init(code: String) -> void:
	self.code = code

## Return a list of defined fields in the code string.
##
## Each element is a dictionary with the keys 'name' and 'prompt'.
func parse_fields() -> Array:
	var re := RegEx.new()
	assert(re.compile(FIELDDEF_REGEX) == OK)
	
	# Look for fields of the form %FIELD:prompt%
	var fields := []
	for field in re.search_all(code):
		var m: RegExMatch = field
		fields.append({
			'name': m.get_string(1),
			'prompt': m.get_string(2)
		})
	
	return fields

## Return the code string with all the fields interpolated.
func interpolate(values: Dictionary) -> String:
	# Compile regex
	var re := RegEx.new()
	assert(re.compile(FIELD_REGEX) == OK)
	
	# Check that there are fields
	var fields := parse_fields()
	if not fields: return code
	
	# Subsitute the fields in the code string
	var new_code := re.sub(code, '{$1}', true)
	return new_code.format(values)

func _is_valid_field(field: Dictionary) -> bool:
	return "name" in field and "prompt" in field
