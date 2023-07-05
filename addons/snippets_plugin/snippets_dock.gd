tool
extends Control

var snippets_path := ""
var ext_editor_path := ""
var config := ConfigFile.new()

func _ready() -> void:
	# Get Initial Snippets Path
	get_snippets_path()
	
	# Get Snippets List
	get_snippets()

## Set the snippets path.
func get_snippets_path() -> void:
	var err := config.load("res://addons/snippets_plugin/snippets_plugin.cfg")
	if err == OK:
		snippets_path = config.get_value("snippets", "snippets_folder")
	
	# Store a variable if and only if it hasn't been defined yet,
	# or if the folder hasn't been found.
	if not config.has_section_key("snippets", "snippets_folder") or not check_dir(snippets_path):
		config.set_value("snippets", "snippets_folder",
			ProjectSettings.globalize_path("res://addons/snippets_plugin/snippets"))
		
		# Save the changes by overwriting the previous file
		config.save("res://addons/snippets_plugin/snippets_plugin.cfg")

## Return true if the directory exists.
func check_dir(path: String) -> bool:
	# Check if folder exists
	var dir := Directory.new()
	if dir.dir_exists(path): return true
	
	return false

## Update the snippets path.
func update_snippets_path():
	# Update snippets config file with current snippets path
	var err := config.load("res://addons/snippets_plugin/snippets_plugin.cfg")
	if err == OK:
		config.set_value("snippets", "snippets_folder", snippets_path)
		config.save("res://addons/snippets_plugin/snippets_plugin.cfg")

## Add the filenames to the tree.
func add_files_to_tree(files: Array) -> void:
	var tree := $menu/Tree
	
	# Clear any existing content (to allow us to repopulate without having to do extra work)
	tree.clear()
	
	# Create the first (root) item
	var root = tree.create_item()
	
	# Enable the "Expand" flag of Control.
	tree.set_column_expand(0, true)
	
	# Hide the root (only display children)
	tree.set_hide_root(true)
	
	var searchbar = $"menu/search-bar/search"
	for _file in files:
		var file: String = _file
		
		if searchbar.text.length() == 0 or file.findn(searchbar.text) != -1:
			var file_node: TreeItem = tree.create_item(root)
			
			# Metadata is used in order to double click
			# the item and copy the file to clipboard
			file_node.set_metadata(0, snippets_path + "/" + file)
			
			# Add Default Snippet description to metadata
			file_node.set_metadata(1, "Snippet Description goes here...")
			
			# The text/name that is displayed in the content tree
			file_node.set_text(0, file)
	
		# Hide the Description Column
		tree.set_column_expand(1, false)

## Return a list of files under the specified PATH.
func list_files_in_directory(path: String) -> Array:
	# List files in a folder
	var files := []
	
	# Open the directory path and start listing files
	var dir := Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	
	while true:
		var file := dir.get_next()
		if file == "": break
		
		# Add text file to the list
		if not dir.current_is_dir() and file.ends_with(".txt"):
			files.append(file)
	
	dir.list_dir_end()
	
	return files

## Delete the file named in 'path'.
func deletefile(path: String) -> void:
	var dir = Directory.new()
	dir.remove(path)

## Save the contents of a string to the file denoted in 'path'.
func savefile(content: String, path: String) -> void:
	var file := File.new()
	file.open(path, file.WRITE)
	file.store_string(content)
	file.close()

## Load the contents of 'path' and return it as a string.
func loadfile(path: String) -> String:
	var file := File.new()
	file.open(path, file.READ)
	var content := file.get_as_text()
	file.close()
	return content

## Copy the contents of the file displayed on the current tree item to clipboard.
func copy_to_clipboard() -> void:
	var file: String = $menu/Tree.get_selected().get_metadata(0)
	OS.set_clipboard(loadfile(file))

#func paste_from_clipboard() -> void:
#	OS.get_clipboard()

## Update the tree with the current list of snippets.
func get_snippets() -> void:
	var snipfiles := list_files_in_directory(snippets_path)
	snipfiles.sort()
	
	add_files_to_tree(snipfiles)
	update_statusbar("Files Refreshed...")

## Display a message on the statusbar.
func update_statusbar(msg: String) -> void:
	$msgTimer.set_wait_time(5)
	$msgTimer.start()
	$menu/Statusbar.text = msg

## Open the selected snippet in an external editor.
func ext_editor() -> void:
	# use external editor
	update_statusbar("Opened in External Editor...")
	
	# get file path from tree node metadata
	var path: String = $menu/Tree.get_selected().get_metadata(0)
	var args := PoolStringArray()
	args.append(path)
	
	# Run command
	OS.execute(ext_editor_path, args, false)

## Open the selected snippet using the shell editor.
func shell_editor() -> void:
	# use shell editor for txt files
	var path: String = $menu/Tree.get_selected().get_metadata(0)
	
	update_statusbar("Handled by txt extension...")
	
	# Open the correct program
	OS.shell_open(path)

## Open the selected snippet using the internal editor.
func int_editor() -> void:
	var path: String = $menu/Tree.get_selected().get_metadata(0)
	$snippet_editor.snippet_path = path
	$snippet_editor/vbox/code.text = loadfile(path)
	$snippet_editor.popup_centered()

func _on_Tree_item_activated() -> void:
	# Edit the text file in default external editor
	$menu/Tree/SnipMenu.rect_position = get_global_mouse_position()
	$menu/Tree/SnipMenu.visible = true
	$menu/Tree/SnipMenu.popup()

func _on_btnRefresh_pressed() -> void:
	# When refresh button pressed get snippets
	get_snippets()

func _on_btnFolder_pressed() -> void:
	# Open filedialog to select folder for snippets
	update_statusbar("Select Snippets Folder...")
	
	$FileDialog.set_mode( FileDialog.MODE_OPEN_DIR)
	$FileDialog.current_dir = snippets_path
	$FileDialog.update()
	
	# Position file dialog at mouse
	$FileDialog.rect_position = get_global_mouse_position()
	$FileDialog.popup()

func _on_btnClipboard_pressed() -> void:
	# Copy contents of selected snippet into clipboard
	if $menu/Tree.get_selected():
		var file: String = $menu/Tree.get_selected().get_metadata(0)
		var snippet := loadfile(file)
		var intp := preload("res://addons/snippets_plugin/interpolator.gd").new(snippet)
		
		# If there are no fields, skip to copying the snippet to the clipboard
		var fields := intp.parse_fields()
		if not fields:
			_on_SnippetParams_cancelled()
			return
		
		# Open the snippets parameters window
		$SnippetParams.activate(fields)
		
		set_meta("interpolator", intp)
	else:
		update_statusbar("Nothing Selected...")

func _on_btnFolder_mouse_entered() -> void:
	# Display snippet filename in tooltip
	$menu/buttons/btnFolder.hint_tooltip = snippets_path

func _on_Tree_item_selected() -> void:
	update_statusbar("Snippet Selected...")

func _on_SnipMenu_id_pressed(ID: int) -> void:
	match ID:
		0:
			# Edit file in internal editor
			int_editor()
		1:
			# Edit file in external editor if defined
			if not ext_editor_path == "":
				ext_editor()
			else:
				# Popup error msg if ext editor not defined
				update_statusbar("External Editor not configured...")
		2:
			# Show file in file manager
			print("Show in File Manager")
			update_statusbar("Opened in File Manager...")
			OS.shell_open($menu/Tree.get_selected().get_metadata(0).get_base_dir())

func _on_Tree_item_rmb_selected(_position) -> void:
	# Display context menu
	$menu/Tree/SnipMenu.rect_position = get_global_mouse_position()
	$menu/Tree/SnipMenu.visible = true
	$menu/Tree/SnipMenu.popup()

func _on_btnAddSnippet_pressed() -> void:
	# Paste clipboard into new snippet
	$FileDialog.set_mode(FileDialog.MODE_SAVE_FILE)
	$FileDialog.current_dir = snippets_path
	$FileDialog.add_filter("*.txt")
	$FileDialog.deselect_items()
	$FileDialog.update()
	$FileDialog.rect_position = get_global_mouse_position()
	$FileDialog.popup()

func _on_btnDelSnippet_pressed() -> void:
	# Delete the selected snippet
	# TODO: Add confirmation dialog
	if $menu/Tree.get_selected():
		# TODO: make function that gets the metadata for column 0
		deletefile($menu/Tree.get_selected().get_metadata(0))
		get_snippets()
	else:
		update_statusbar("Nothing Selected...")

func _on_msgTimer_timeout() -> void:
	# When timer times out (5secs) clear text from statusbar
	$menu/Statusbar.text = ""

func _on_FileDialog_file_selected(path: String) -> void:
	# Save the contents of the clipboard to file
	savefile(OS.get_clipboard(), path)
	update_statusbar("Snippet Added...")
	get_snippets()

func _on_FileDialog_dir_selected(dir: String) -> void:
	# If dir selected then update the snippets folder in config file
	snippets_path = dir
	update_snippets_path()
	update_statusbar("Folder Selected...")
	get_snippets()

func _on_btnHelp_pressed() -> void:
	# Show help windows dialog
	$Help.rect_position = get_global_mouse_position()
	$Help.popup()

func _on_LineEdit_text_changed(text: String) -> void:
	get_snippets()

func _on_SnippetParams_params_confirmed(params: Array) -> void:
	# Confirmed snippet parameters
	var dparams := {}
	for param in params:
		dparams[param.name] = param.value
	
	var intp = get_meta("interpolator")
	if intp:
		var snippet: String = intp.interpolate(dparams)
		OS.set_clipboard(snippet)
		update_statusbar("Copied to Clipboard...")

func _on_SnippetParams_cancelled() -> void:
	# When no parameters are provided.
	copy_to_clipboard()
	update_statusbar("Copied to Clipboard...")
