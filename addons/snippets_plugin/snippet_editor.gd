tool
extends WindowDialog

var snippet_path := ""

# Flags
var save_prompt: bool

# Make simpler
onready var menu: PopupMenu = $vbox/code.get_menu()
onready var editor: TextEdit = $vbox/code

## Context menu IDs.
enum ContextMenuID {LINE_NUMBERS, LINE_HIGHLIGHT, SYNTAX_HIGHLIGHT}

func _ready():
	# Set flags
	save_prompt = false
	
	setup_menu()
	
	# Setup Editor
	$vbox/menu/btnSave.disabled = true
	
	$vbox/menu/btnNumbers.pressed = false
	$vbox/menu/btnHighlight.pressed = false
	$vbox/menu/btnSyntax.pressed = false

## Populate the popup menu of the text box.
func setup_menu():
	editor.set_context_menu_enabled(true)
	
	menu.add_separator()
	menu.add_item("Line Numbers", ContextMenuID.LINE_NUMBERS)
	menu.add_item("Line Highlight", ContextMenuID.LINE_HIGHLIGHT)
	menu.add_item("Syntax Highlight", ContextMenuID.SYNTAX_HIGHLIGHT)

	# Setup Signal for added entries
	menu.connect("id_pressed", self, "_on_menu_item_pressed")

## Save a string to a file pointed to by 'path'.
func savefile(content: String, path: String):
	var file = File.new()
	file.open(path, file.WRITE)
	file.store_string(content)
	file.close()

## Load a file and return its contents as a string.
func loadfile(path: String) -> String:
	var file := File.new()
	file.open(path, file.READ)
	
	var content := file.get_as_text()
	file.close()
	return content

## Close the current snippet.
func quit():
	if save_prompt == true:
		save_prompt = false
		$vbox/menu/btnSave.disabled = true
		_show_save_dialog()

func _show_save_dialog() -> void:
	# Save or Save As File
	$FileDialog.current_path = snippet_path
	$FileDialog.set_mode(FileDialog.MODE_SAVE_FILE)
	$FileDialog.resizable = true
	$FileDialog.visible = true
	$FileDialog.popup_centered_ratio(0.5)

func _on_menu_item_pressed(ID: int) -> void:
	var label: String = menu.get_item_text(ID)
	
	# Check for added context menu items
	match label:
		"Line Numbers":
			# Line number toggle method
			editor.show_line_numbers = $vbox/menu/btnNumbers.pressed
		"Line Highlight":
			# Line highlight toggle method
			editor.highlight_current_line = $vbox/menu/btnHighlight.pressed
		"Syntax Highlight":
			# Syntax highlight toggle method
			editor.syntax_highlighting = $vbox/menu/btnSyntax.pressed

func _on_FileDialog_file_selected(path: String) -> void:
	# Confirm save file
	if $FileDialog.MODE_SAVE_FILE:
		if $FileDialog.current_file != "":
			savefile(editor.text, ProjectSettings.globalize_path($FileDialog.current_path))

func _on_snippet_editor_hide() -> void:
	# Close the snippet
	quit()

func _on_code_text_changed() -> void:
	# Highlight the save button
	$vbox/menu/btnSave.disabled = false
	save_prompt = true

func _on_btnSave_pressed() -> void:
	# Save file
	save_prompt = false
	$vbox/menu/btnSave.disabled = true
	
	_show_save_dialog()

func _on_btnSyntax_toggled(button_pressed: bool) -> void:
	# Line hightlight toggle method
	editor.syntax_highlighting = button_pressed

func _on_btnHighlight_toggled(button_pressed: bool) -> void:
	# Line hightlight toggle method
	editor.highlight_current_line = button_pressed

func _on_btnNumbers_toggled(button_pressed: bool) -> void:
	# Line number toggle method
	editor.show_line_numbers = button_pressed
