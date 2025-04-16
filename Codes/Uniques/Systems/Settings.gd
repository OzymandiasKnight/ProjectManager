extends Control

@onready var obj_background:Panel = get_node("Background")

@onready var obj_left_vertical:VBoxContainer = get_node("LeftVertical")
@onready var obj_relative_speed:CheckBox = obj_left_vertical.get_node("MouseSpeed/RelativeSpeed")

@onready var obj_right_vertical:VBoxContainer = get_node("RightVertical")
@onready var obj_color_main:LineEdit = obj_right_vertical.get_node("MainColor/Color")
@onready var obj_color_secondary:LineEdit = obj_right_vertical.get_node("SecondaryColor/SColor")
@onready var obj_color_background:LineEdit = obj_right_vertical.get_node("BackgroundColor/BColor")

@onready var obj_project_manager:Node2D

func _ready():
	obj_project_manager = get_parent().get_parent().get_parent().get_parent()
	System.connect("color_changed",color_changed)
	obj_color_main.text = System.get_color("color_main").to_html()
	obj_color_secondary.text = System.get_color("color_secondary").to_html()
	obj_color_background.text = System.get_color("color_background").to_html()
	System.emit_signal("color_changed")
	obj_relative_speed.button_pressed = System.settings["relative_speed"]

func _input(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("escape"):
			if not (obj_project_manager.obj_project_creation.visible or obj_project_manager.obj_project_modification.visible):
				get_parent().visible = !get_parent().visible

func color_changed():
	obj_color_main.get_node("Color").color = System.get_color("color_main")
	obj_color_secondary.get_node("Color").color = System.get_color("color_secondary")
	obj_color_background.get_node("Color").color = System.get_color("color_background")
	
	obj_background.modulate = System.get_color("color_secondary")


func _on_color_text_changed(new_text:String):
	var color = Color(new_text)
	color.a = 1.0
	System.set_color("color_main",color)


func _on_s_color_text_changed(new_text:String):
	var color = Color(new_text)
	color.a = 1.0
	System.set_color("color_secondary",color)


func _on_b_color_text_changed(new_text:String):
	var color = Color(new_text)
	color.a = 1.0
	System.set_color("color_background",color)


func _on_relative_speed_toggled(toggled_on:bool):
	System.settings["relative_speed"] = toggled_on
	System.save_settings()


func _on_folder_pressed():

	var path_user:String = OS.get_user_data_dir()+"/projects"
	OS.shell_show_in_file_manager(path_user)


func _on_compression_toggled(toggled_on):
	System.settings["image_compression"] = toggled_on
	System.save_settings()
