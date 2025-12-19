@tool
extends Control

const RightClickHandler = preload("res://addons/addon_lib/brohd/gui_click_handler/right_click_handler.gd")
const FileSystemTab = preload("res://addons/addon_lib/brohd/alib_editor/file_system/tree/filesystem_tab.gd")

@onready var dock_button: Button = %DockButton

@onready var v_box: VBoxContainer = %VBox
@onready var tab_bar: TabBar = %TabBar

@onready var right_click_handler: RightClickHandler = $RightClickHandler



func set_dock_data(data:Dictionary):
	if data.is_empty():
		_add_tab()
		get_tab_control(0).show()
		return
	
	var tabs_data = data.get("tabs_data")
	if tabs_data.is_empty():
		_add_tab()
		get_tab_control(0).show()
		return
	
	for idx:String in tabs_data.keys():
		var tab_data = tabs_data.get(idx)
		var root = tab_data.get("root")
		_add_tab(root)
		var title = tab_data.get("title")
		var item_meta = tab_data.get("item_meta", {})
		var idx_as_int = idx.to_int()
		var tab_control = get_tab_control(idx_as_int) as FileSystemTab
		tab_control.tree.tree_helper.data_dict = item_meta
		
		
	
	var current_tab = data.get("current_tab", 0)
	tab_bar.current_tab = current_tab
	get_tab_control(current_tab).show()

func get_dock_data():
	var data = {}
	data["current_tab"] = tab_bar.current_tab
	var tabs_data = {}
	for i in range(tab_bar.get_tab_count()):
		var tab_control = v_box.get_child(i) as FileSystemTab
		var tab_data = {}
		var tree = tab_control.tree as FileSystemTab.FileSystemTree
		tab_data["root"] = tree.root_dir
		tab_data["title"] = tab_bar.get_tab_title(i)
		tab_data["item_meta"] = tree.tree_helper.data_dict
		tabs_data[i] = tab_data
	
	data["tabs_data"] = tabs_data
	return data


func _ready() -> void:
	if is_part_of_edited_scene():
		return
	tab_bar.tab_clicked.connect(_on_tab_clicked)
	tab_bar.tab_rmb_clicked.connect(_on_tab_rmb_clicked)
	tab_bar.tab_close_pressed.connect(_close_tab)
	tab_bar.mouse_entered.connect(_on_tab_bar_mouse_entered)
	tab_bar.mouse_exited.connect(_on_tab_bar_mouse_exited)
	tab_bar.tab_changed.connect(_on_tab_changed)
	
	dock_button.theme_type_variation = &"MainScreenButtons"
	
	await get_tree().process_frame
	if tab_bar.tab_count == 0:
		_add_tab()
		get_tab_control(0).show()

func _set_panel_size():
	tab_bar.get_parent().custom_minimum_size.y = tab_bar.size.y

func _add_tab(dir:="res://"):
	var new_tab = FileSystemTab.get_scene().instantiate() as FileSystemTab
	v_box.add_child(new_tab)
	new_tab.hide()
	new_tab.set_dir(dir)
	var title = "FileSystem"
	if dir != "res://":
		title = dir.trim_suffix("/").get_file()
	tab_bar.add_tab(title)
	var last_tab = tab_bar.tab_count - 1
	tab_bar.set_tab_tooltip(last_tab, dir)
	tab_bar.set_tab_metadata(last_tab, new_tab)
	
	new_tab.tree.new_tab.connect(_add_tab)
	
	await get_tree().process_frame
	_set_panel_size()


func get_tab_control(tab:int):
	return tab_bar.get_tab_metadata(tab)

func _on_tab_clicked(tab:int):
	_show_tab(tab)

func _show_tab(tab):
	for i in range(tab_bar.tab_count):
		var tab_control = get_tab_control(i)
		if i == tab:
			tab_control.show()
		else:
			tab_control.hide()


func _close_tab(tab:int):
	var control = get_tab_control(tab)
	tab_bar.remove_tab(tab)
	control.queue_free()
	_on_tab_clicked(tab_bar.current_tab)


func _on_tab_changed(tab:int):
	var control = get_tab_control(tab)
	if not is_instance_valid(control):
		return
	if control.get_parent() != v_box:
		control.reparent(v_box)
	_show_tab(tab)


func _on_tab_bar_mouse_entered():
	var window = get_window()
	if window.gui_is_dragging():
		var drag_data = window.gui_get_drag_data()
		var from_path = drag_data.get("from_path")
		if from_path == null:
			return
		var from_node:TabBar = Engine.get_main_loop().root.get_node(from_path)
		var hovered_node = window.gui_get_hovered_control()
		if hovered_node is not TabBar:
			return
		if from_node == tab_bar:
			return
		else:
			if from_node.get_tab_count() <= 1:
				tab_bar.tabs_rearrange_group = -1
			else:
				tab_bar.tabs_rearrange_group = 0


func _on_tab_bar_mouse_exited():
	tab_bar.tabs_rearrange_group = 0



func _on_tab_rmb_clicked(tab:int):
	var options = RightClickHandler.Options.new()
	if tab_bar.tab_count > 1:
		options.add_option("Close", _close_tab.bind(tab), ["Close"])
	
	right_click_handler.display_popup(options)
