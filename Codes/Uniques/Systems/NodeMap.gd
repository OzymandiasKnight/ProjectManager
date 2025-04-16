extends Control

var pre_node_pointer = preload("res://Scenes/Instances/Interface/NodePointer.tscn")

@onready var obj_center:CenterContainer = get_node("Center")
@onready var obj_circle:Sprite2D = obj_center.get_node("Control/Circle")

func _ready():
	System.connect("color_changed",color_changed)
	color_changed()

func color_changed():
	obj_circle.self_modulate = System.get_color("color_secondary")

func add_node(node:WorkNode):
	var pointer:Node2D = pre_node_pointer.instantiate()
	pointer.node = node
	obj_circle.add_child(pointer)

func reset_nodes():
	for pointer in obj_circle.get_children():
		pointer.queue_free()

func check_circle_visibility():
	var visible_nodes:int = 0
	for node in obj_circle.get_children():
		visible_nodes += float(node.visible)
	if visible_nodes == 0:
		obj_circle.visible = false
	else:
		obj_circle.visible = true
