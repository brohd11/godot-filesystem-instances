extends EditorContextMenuPlugin

const SLOT = CONTEXT_SLOT_FILESYSTEM

const SCENE_PREVIEW = "FileSystem/Generate 3D Scene Preview"

func _popup_menu(paths: PackedStringArray) -> void:
	
	var valid_items = get_valid_items(paths)
	PopupWrapper.create_context_plugin_items(self, paths, valid_items, _on_popup_pressed)


func _on_popup_pressed(paths, item_name):
	if item_name == SCENE_PREVIEW:
		var scenes = []
		for p in paths:
			if FileSystemSingleton.get_file_type_static(p) == "PackedScene":
				scenes.append(p)
		FileSystemSingleton.generate_scene_previews(scenes)


func get_valid_items(paths: PackedStringArray) -> Dictionary:
	var options = ALibRuntime.Popups.Options.new()
	for p in paths:
		if FileSystemSingleton.get_file_type_static(p) == "PackedScene":
			options.add_option(SCENE_PREVIEW, null, ["Filesystem", "Texture2D"])
			break
	
	return options.get_options()
