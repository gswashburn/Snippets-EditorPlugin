tool
extends WindowDialog

## Emitted when the OK button is pressed.
##
## Returns the parameters as an array of dictionaries
## with the keys 'name' and 'value'.
signal params_confirmed(params)

## Emitted when the cancel button is pressed.
signal cancelled

const SnippetParam = preload("res://addons/snippets_plugin/params/SnippetParameter.gd")
const SnippetParamScene = preload("res://addons/snippets_plugin/params/SnippetParameter.tscn")

func _ready() -> void:
	var btn = get_close_button()
	btn.hide()

## Activate the window, displaying it with one or more snippet parameters.
##
## For each parameter defined, a snippet parameter widget is created and added
## to the window.
func activate(params: Array) -> void:
	for param in params:
		var snippet_param = SnippetParamScene.instance()
		snippet_param.property_name = param.name
		snippet_param.prompt = param.prompt
		snippet_param.name = "Param_" + param.name
		$VBoxContainer/MarginContainer/Params.add_child(snippet_param)
	
	popup_centered()

func _get_params() -> Array:
	# Get all the snippet parameters as an array
	var params := []
	for node in $VBoxContainer/MarginContainer/Params.get_children():
		# Add a dictionary of the parameter to the array
		var param: SnippetParam = node
		params.append({
			name = param.property_name,
			value = param.get_property_value()
		})
	
	return params

func _on_btnOK_pressed() -> void:
	# When the OK button is pressed
	var params := _get_params()
	deactivate()
	emit_signal("params_confirmed", params)

func _on_btnCancel_pressed() -> void:
	# When the Cancel button is pressed
	# Hide the window and clean it up
	deactivate()
	emit_signal("cancelled")

## Deactivate the window, hiding it and doing any necessary cleanup.
func deactivate() -> void:
	hide()
	for node in $VBoxContainer/MarginContainer/Params.get_children():
		(node as Node).queue_free()
