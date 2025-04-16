extends Control

signal add_node(node:WorkNode,position)

var sliding_node:Control = null

@onready var obj_drag_node:Control = get_node("Effect")

func _ready():
	obj_drag_node.visible = false

func set_sliding(node:Control):
	sliding_node = node
	set_drag_node_at_mouse()
	obj_drag_node.visible = true
	obj_drag_node.get_node("Animation").play("Select")

func _input(event):
	if event is InputEventMouseButton:
		if Input.is_action_just_released("left_click"):
			if sliding_node:
				obj_drag_node.visible = false
				emit_signal("add_node",sliding_node,get_parent().get_parent().get_parent().get_global_mouse_position())
				sliding_node = null
				

	if event is InputEventMouseMotion:
		if sliding_node:
			set_drag_node_at_mouse()
			
func set_drag_node_at_mouse():
	obj_drag_node.global_position = Cursor.get_cursor_position()-Vector2(25,25)
