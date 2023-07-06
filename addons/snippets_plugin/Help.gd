tool
extends WindowDialog

const HELPFILE := "res://addons/snippets_plugin/help.txt"

func _ready() -> void:
	var file := File.new()
	if not file.open(HELPFILE, File.READ):
		$Label.bbcode_enabled = true
		$Label.bbcode_text = file.get_as_text()
