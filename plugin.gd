@tool
extends EditorPlugin

const SCENE = preload("res://addons/filesystem_instances/src/tree_tab_container.tscn")

var main_fs_inst

var dm_instance_manager:DockManager.InstanceManager
var filesystem_singleton:FileSystemSingleton

func _get_plugin_name() -> String:
	return "Filesystem Instances"

func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_base_control().get_theme_icon("FileTree", "EditorIcons")


func _enter_tree() -> void:
	add_tool_menu_item("FileSystem Instance", _on_tool_menu_pressed)
	
	filesystem_singleton = FileSystemSingleton.register_node(self)
	filesystem_singleton.call_on_ready(_instance_manager)
	
	#var fs_dock = EditorInterface.get_file_system_dock()
	#main_fs_inst = SCENE.instantiate()
	#fs_dock.get_child(3).get_child(0).add_child(main_fs_inst)
	#main_fs_inst.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	

func _instance_manager():
	dm_instance_manager = DockManager.InstanceManager.new(self, true)

func _exit_tree() -> void:
	if is_instance_valid(main_fs_inst):
		main_fs_inst.queue_free()
	if is_instance_valid(filesystem_singleton):
		filesystem_singleton.unregister_node(self)
	
	if is_instance_valid(dm_instance_manager):
		dm_instance_manager.clean_up()
	
	remove_tool_menu_item("FileSystem Instance")


func _on_tool_menu_pressed():
	var ins = dm_instance_manager.new_freeable_dock_manager(SCENE, DockManager.Slot.DOCK_SLOT_LEFT_BR)
	ins.allow_scene_reload = true
