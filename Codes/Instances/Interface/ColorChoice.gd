extends Control

var icon_paths:String = "res://Textures/Instances/Icons/"

#Exports
@export var color:Color

#Objects
@onready var obj_panel = get_node("Panel")
@onready var obj_icon = get_node("Icon")

func _ready():
	if get_parent().name == "Icons":
		var icon:Texture2D = null
		if name != "null":
			icon = load(icon_paths+name+".svg")
		obj_icon.texture = icon
	
	if color:
		obj_icon.texture = null
		set_color(color)
	else:
		set_color(ProjectHandler.default_group_color)
	

func set_color(col:Color):
	obj_panel.self_modulate = col
	obj_icon.material.set_shader_parameter("color",col)
	

func _on_panel_gui_input(event):
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("left_click"):
			if get_parent().name == "Icons":
				get_parent().get_parent().get_parent().get_parent().get_parent().set_icon(name)
			else:
				get_parent().get_parent().get_parent().get_parent().get_parent().set_color(color)
