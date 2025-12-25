@tool
extends EditorPlugin

const PluginTabContainer = preload("uid://ctutcmmga2vy6") # tree_tab_container.gd
const SCENE = preload("uid://2dvub2jcbmvm") # tree_tab_container.tscn

var settings_helper:ALibEditor.SettingHelper
var _hide_filesystem:bool = false

var dm_instance_manager:DockManager.InstanceManager
var filesystem_singleton:FileSystemSingleton

func _get_plugin_name() -> String:
	return "Files"

func _get_plugin_icon() -> Texture2D:
	#return EditorInterface.get_base_control().get_theme_icon("Folder", "EditorIcons")
	return EditorInterface.get_base_control().get_theme_icon("FileTree", "EditorIcons")


func _enter_tree() -> void:
	add_tool_menu_item("FileSystem Instance", _on_tool_menu_pressed)
	
	filesystem_singleton = FileSystemSingleton.register_node(self)
	filesystem_singleton.call_on_ready(_instance_manager)
	
	settings_helper = ALibEditor.SettingHelper.new(self)
	settings_helper.subscribe(&"_hide_filesystem", &"plugin/filesystem_instances/hide_editor_file_system", false)
	settings_helper.initialize()
	
	EditorNodeRef.call_on_ready(_hide_fs)

func _instance_manager():
	dm_instance_manager = DockManager.InstanceManager.new(self, true)

func _exit_tree() -> void:
	if is_instance_valid(filesystem_singleton):
		filesystem_singleton.unregister_node(self)
	if is_instance_valid(dm_instance_manager):
		dm_instance_manager.clean_up()
	
	remove_tool_menu_item("FileSystem Instance")


func _on_tool_menu_pressed():
	var plugin_container = PluginTabContainer.get_instance(["uid://dmi6v1vnl5tug"]) # filesystem_tab.gd
	plugin_container.name = "Files"
	var ins = dm_instance_manager.new_freeable_dock_manager(plugin_container, DockManager.Slot.DOCK_SLOT_LEFT_BR)
	ins.allow_scene_reload = true


func _hide_fs():
	if _hide_filesystem:
		while not FileSystemSingleton.fs_dock_in_bottom_panel():
			await get_tree().process_frame
		FileSystemSingleton.hide_filesystem()
	else:
		if FileSystemSingleton.fs_dock_in_bottom_panel():
			FileSystemSingleton.show_filesystem()
