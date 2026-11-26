extends "res://addons/_lib/popup_wrapper/src/context_menu.gd" #! ext PopupWrapper.ContextMenu

const Options = UtilR.Nodes.PopupMenus.Options

const SLOT = CONTEXT_SLOT_FILESYSTEM

const SCENE_PREVIEW = "FileSystem/Generate 3D Scene Preview"

func _get_menu_options(data) -> void:
	var paths = PopupWrapper.Slots.selected_files(data)
	
	var valid_items = get_valid_items(paths)
	PopupWrapper.ContextPlugin.create_items(self, data, valid_items, _on_popup_pressed)


func _on_popup_pressed(data, item_name):
	var paths = PopupWrapper.Slots.selected_files(data)
	if item_name == SCENE_PREVIEW:
		var scenes = []
		for p in paths:
			if FileSystemSingleton.get_file_type_static(p) == "PackedScene":
				scenes.append(p)
		FileSystemSingleton.generate_scene_previews(scenes)


func get_valid_items(paths: PackedStringArray) -> Dictionary:
	var options = Options.new()
	for p in paths:
		if FileSystemSingleton.get_file_type_static(p) == "PackedScene":
			options.add_option(SCENE_PREVIEW, null, ["Filesystem", "Texture2D"])
			break
	
	return options.get_options()
