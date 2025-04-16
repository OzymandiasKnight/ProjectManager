extends CanvasLayer

@onready var obj_window:Control = get_node("Window")
@onready var obj_options:Control = obj_window.get_node("SelectionMenu")
@onready var obj_add:Control = obj_window.get_node("WorkNodeMenu")
@onready var obj_path:Control = obj_window.get_node("Path")
@onready var obj_nodemap:Control = obj_window.get_node("NodeMap")
@onready var obj_circular_map:Control = obj_nodemap.get_node("Centerer/CircularMap")

func _ready():
	obj_options.edited_node = null
	obj_options.set_edited_node(obj_options.edited_node)

func set_node_options(node:WorkNode,update=false):
	obj_options.set_edited_node(node,update)

func show_option_menu(show):
	obj_add.visible = !show
	obj_options.visible = show

func reset_pointers():
	if obj_circular_map:
		obj_circular_map.reset_nodes()

func add_pointer(track_node:WorkNode):
	if obj_circular_map:
		obj_circular_map.add_node(track_node)

func set_project_name(new_name:String):
	obj_path.set_project_name(new_name)
