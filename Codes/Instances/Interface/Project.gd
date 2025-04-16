extends Control

var number_of_nodes:int = 0
var number_of_groups:int = 0

@onready var obj_offset:Control = get_node("Offset")
@onready var obj_card:Panel = obj_offset.get_node("Card")
@onready var obj_band:Panel = obj_offset.get_node("Band/Color")
@onready var obj_informations:Control = obj_offset.get_node("Informations/Vertical")
@onready var obj_nodes:Label = obj_informations.get_node("Nodes")
@onready var obj_groups:Label = obj_informations.get_node("Groups")

@onready var obj_name:Label = obj_offset.get_node("Band/Name")

var project_name:String = ""

@onready var obj_animations:AnimationPlayer = get_node("Animations")

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.double_click:
			if Input.is_action_pressed("left_click"):
				load_project()
		else:
			if Input.is_action_just_pressed("right_click"):
				get_parent().get_parent().get_parent().get_parent().get_parent().modify_project(project_name)

func _ready():
	System.connect("color_changed",color_changed)
	color_changed()
	obj_name.text = project_name
	obj_nodes.text += str(number_of_nodes)
	obj_groups.text += str(number_of_groups)

func color_changed():
	obj_card.modulate = System.get_color("color_secondary")
	obj_band.modulate = System.get_color("color_main")

func load_project():
	ProjectHandler.project_name = project_name
	get_parent().get_parent().get_parent().get_parent().get_parent().load_project(name)



func _on_mouse_entered():
	obj_animations.play("Hover")


func _on_mouse_exited():
	obj_animations.play_backwards("Hover")
