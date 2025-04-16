extends Node2D

@onready var obj_mouse:Node2D = get_node("Mouse")

var hovered_group:WorkNode = null

func _ready():
	pass

func _input(event):
	if event is InputEventMouseMotion:
		obj_mouse.position = get_cursor_global_position()

func get_cursor_position() -> Vector2:
	return get_viewport().get_mouse_position()

func get_cursor_global_position() -> Vector2:
	return get_global_mouse_position()

func open_file():
	pass


func _on_group_detection_area_entered(area):
	var work_node = area.get_parent()
	if work_node is WorkNode:
		if work_node.type == "Group":
			hovered_group = work_node


func _on_group_detection_area_exited(area):
	if hovered_group:
		hovered_group = null
