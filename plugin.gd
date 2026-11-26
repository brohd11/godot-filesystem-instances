@tool
extends EditorPlugin
const FSClasses = preload("res://addons/_lib/editor_filesystem/src/util/fs_classes.gd")
const FSUtil = FSClasses.FSUtil
const EditorGlobalSignals = FSUtil.EditorGlobalSignals

const PluginSplitPanel = preload("res://addons/_lib/editor_panels/src/plugin_split_panel.gd")
const PluginTabContainer = preload("res://addons/_lib/editor_panels/src/plugin_tab_container.gd")

const FileSystemTab = preload(TAB_PATH)
const TAB_PATH = "res://addons/_lib/editor_filesystem/src/fs_tab/filesystem_tab.gd" #! ensure-path

const ContextMenuPlugin = preload("res://addons/filesystem_instances/src/context_menu/context_menu_plugin.gd")

var dm_instance_manager:DockManager.InstanceManager

var editor_plugin_manager:PluginManager.Editor

func _get_plugin_name() -> String:
	return "Files"

func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_base_control().get_theme_icon("FileTree", "EditorIcons")


func _enter_tree() -> void:
	add_tool_menu_item("FileSystem Instance", _on_tool_menu_pressed)
	
	FileSystemTab.EditorSet.ensure_settings()
	
	FileSystemSingleton.register_node(self)
	FileSystemSingleton.call_on_ready(_instance_manager)
	
	editor_plugin_manager = PluginManager.Editor.new(self)
	editor_plugin_manager.add_context_menu_plugins([ContextMenuPlugin])

	EditorGlobalSignals.subscribe(FileSystemTab.DataKeys.GLOBAL_NEW_WINDOW_SIGNAL, new_window)
	EditorGlobalSignals.subscribe(FileSystemTab.DataKeys.GLOBAL_NEW_SPLIT_SIGNAL, new_split)
	
	EditorPanelSingleton.register_tab("FileSystem", TAB_PATH)
	
	var layout = PluginSplitPanel.Layout.new()
	layout.add_panel(PluginTabContainer.get_scene_path(), {
		"default_tabs":[TAB_PATH]
	})
	var icon = FSUtil.EditorIcons.get_icon("FileTree")
	EditorPanelSingleton.register_layout("FileSystem", layout, icon)


func _instance_manager():
	dm_instance_manager = DockManager.InstanceManager.new(self, true)

func _exit_tree() -> void:
	FileSystemSingleton.reset_dialogs()
	FileSystemSingleton.unregister_node(self)
	
	if is_instance_valid(dm_instance_manager):
		dm_instance_manager.clean_up()
	if is_instance_valid(editor_plugin_manager):
		editor_plugin_manager.remove_plugins()
	
	remove_tool_menu_item("FileSystem Instance")


func _on_tool_menu_pressed():
	var plugin_split_panel = PluginSplitPanel.new()
	var ins = dm_instance_manager.new_freeable_dock_manager(plugin_split_panel, DockManager.DOCK_SLOT_NONE)
	ins.allow_scene_reload = true
	
	var layout_data = EditorPanelSingleton.get_layout("FileSystem")
	plugin_split_panel.load_layout(layout_data.get("layout"))



func new_window(data:Dictionary):
	var tab_data = PluginTabContainer.Tabs.new()
	tab_data.add_tab("FileSystem", TAB_PATH, data)
	
	var layout = PluginSplitPanel.Layout.new()
	layout.add_panel(PluginTabContainer.get_scene_path(), tab_data.get_data())
	
	var plugin_split_panel = PluginSplitPanel.new()
	var ins = dm_instance_manager.new_freeable_dock_manager(plugin_split_panel, DockManager.DOCK_SLOT_NONE)
	ins.allow_scene_reload = true
	plugin_split_panel.load_layout(layout)

func new_split(calling_node:Node, direction:String, data:Dictionary):
	var split = EditorPanelSingleton.get_split_panel_ancestor(calling_node) as PluginSplitPanel
	if not is_instance_valid(split):
		printerr("Could not find split container.")
		return
	
	var tab_container = PluginTabContainer.new()
	tab_container.load_default = false
	
	var split_dir := PluginSplitPanel.SplitType.HORIZONTAL_L
	if direction == FileSystemTab.FSPopupHandler.NEW_SPLIT_LEFT:
		pass
	elif direction == FileSystemTab.FSPopupHandler.NEW_SPLIT_RIGHT:
		split_dir = PluginSplitPanel.SplitType.HORIZONTAL_R
	elif direction == FileSystemTab.FSPopupHandler.NEW_SPLIT_UP:
		split_dir = PluginSplitPanel.SplitType.VERTICAL_U
	elif direction == FileSystemTab.FSPopupHandler.NEW_SPLIT_DOWN:
		split_dir = PluginSplitPanel.SplitType.VERTICAL_D
	
	split.new_split(calling_node, tab_container, split_dir)
	
	var tab = FileSystemTab.new()
	tab.set_dock_data(data)
	tab_container.add_tab(tab)
