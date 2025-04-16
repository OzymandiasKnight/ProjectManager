extends WorkNode

@export var color:Color = Color.WHITE:
	set(new_color):
		color = new_color
		if obj_panel:
			obj_panel.self_modulate = color
			obj_icon.material.set_shader_parameter("color",color)

@export var icon:String:
	set(new_icon):
		icon = new_icon
		if obj_icon:
			obj_icon.texture = load_icon_from_name()

@onready var obj_panel:Panel = get_node("Panel")
@onready var obj_icon:Sprite2D = get_node("Icon")

func _ready():
	super()
	color = color
	obj_icon.texture = load_icon_from_name()

func load_icon_from_name() -> Texture2D:
	var texture:Texture2D = null
	if icon != "null" and icon != "":
		texture = load("res://Textures/Instances/Icons/" + icon + ".svg")
	return texture



func _on_slide_detection_area_entered(area):
	get_node("Hover").play("Hover")


func _on_slide_detection_area_exited(area):
	get_node("Hover").play_backwards("Hover")
