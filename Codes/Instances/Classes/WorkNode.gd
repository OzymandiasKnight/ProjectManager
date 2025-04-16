extends Control
class_name WorkNode

signal deleted

@export_enum("Group","Note","Image") var type:String

##Modify animation name : Modify
@export var animation_modify:AnimationPlayer
@export var animation_hover:AnimationPlayer

@onready var obj_name:Label = get_node("Name")

var id:int = 0

var visible_notification:VisibleOnScreenNotifier2D = VisibleOnScreenNotifier2D.new()


@export var node_name:String = type:
	set(new_value):
		node_name = new_value
		if obj_name:
			obj_name.text = node_name

func _ready():
	add_child(visible_notification)

	node_name = node_name
	connect("gui_input",on_gui_input)
	connect("mouse_entered", hover)
	connect("mouse_exited", unhover)
	connect("resized", size_changed)
	
	size_changed()

func size_changed():
	visible_notification.rect = Rect2(Vector2(0,0),size)

func on_gui_input(event):
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("right_click"):
			modify()
		else:
			if event.double_click:
				if Input.is_action_pressed("left_click"):
					used()
			else:
				if Input.is_action_just_pressed("left_click"):
					get_dragged()

func hover():
	if animation_hover:
		animation_hover.play("Hover")

func unhover():
	if animation_hover:
		animation_hover.play_backwards("Hover")

func modify():
	if animation_modify:
		animation_modify.play("Modify")
	get_parent().get_parent().obj_ui.set_node_options(self)

func unmodify():
	if animation_modify:
		animation_modify.play_backwards("Modify")

func delete():
	emit_signal("deleted")
	queue_free()

func used():
	get_parent().get_parent().use_node(self)

func get_dragged():
	get_parent().get_parent().moving_node = self
