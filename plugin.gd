@tool
extends EditorPlugin

const PluginSplitPanel = preload("res://addons/addon_lib/brohd/alib_editor/editor_panel/plugin_split_panel.gd")
const PLUGIN_TAB_CONTAINER = "uid://2dvub2jcbmvm" # tree_tab_container.tscn

const TAB_PATH = "res://addons/addon_lib/brohd/alib_editor/file_system/components/filesystem_tab.gd" #! ensure-path

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

	
	EditorPanelSingleton.register_tab("FileSystem", TAB_PATH)
	
	var layout = PluginSplitPanel.Layout.new()
	layout.add_panel(PLUGIN_TAB_CONTAINER, {
		"default_tabs":[TAB_PATH]
	})
	var icon = EditorInterface.get_base_control().get_theme_icon("FileTree", "EditorIcons")
	EditorPanelSingleton.register_layout("FileSystem", layout, icon)


func _instance_manager():
	dm_instance_manager = DockManager.InstanceManager.new(self, true)

func _exit_tree() -> void:
	if is_instance_valid(filesystem_singleton):
		filesystem_singleton.unregister_node(self)
	if is_instance_valid(dm_instance_manager):
		dm_instance_manager.clean_up()
	
	remove_tool_menu_item("FileSystem Instance")


func _on_tool_menu_pressed():
	var plugin_split_panel = PluginSplitPanel.new()
	var ins = dm_instance_manager.new_freeable_dock_manager(plugin_split_panel, DockManager.Slot.DOCK_SLOT_LEFT_BR)
	ins.allow_scene_reload = true
	
	#var layout = PluginSplitPanel.Layout.new()
	#layout.add_panel(PLUGIN_TAB_CONTAINER, {
		#"default_tabs":["res://addons/addon_lib/brohd/alib_editor/file_system/tree/filesystem_tab.gd"]
	#})
	
	#plugin_split_panel.load_layout(layout)
	var layout_data = EditorPanelSingleton.get_layout("FileSystem")
	plugin_split_panel.load_layout(layout_data.get("layout"))
	


func _hide_fs():
	if _hide_filesystem:
		while not FileSystemSingleton.fs_dock_in_bottom_panel():
			await get_tree().process_frame
		FileSystemSingleton.hide_filesystem()
	else:
		if FileSystemSingleton.fs_dock_in_bottom_panel():
			FileSystemSingleton.show_filesystem()
