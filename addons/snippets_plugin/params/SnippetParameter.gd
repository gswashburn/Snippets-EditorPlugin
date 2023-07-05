tool
extends HBoxContainer

export var property_name: String
export var prompt := "Prompt" setget set_prompt

func _on_PropertyValue_text_entered(_new_text: String) -> void:
	$"%enPropertyValue".release_focus()

## Get the property value.
func get_property_value() -> String:
	return $"%enPropertyValue".text

## Set the prompt
func set_prompt(new_prompt: String) -> void:
	prompt = new_prompt
	$"%lblPrompt".text = prompt
