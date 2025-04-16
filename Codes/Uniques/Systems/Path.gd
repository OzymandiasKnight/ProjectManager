extends Control
@export var project_name:String = "Default"
@onready var obj_path:Label = get_node("Path")
@onready var obj_project:Control = get_node("Project")
@onready var obj_panel:Panel = get_node("Panel")

const path_manager:String = "res://Scenes/Uniques/Menus/ProjectManager.tscn"

signal back_path()

func _ready():
	System.connect("color_changed",color_changed)
	color_changed()
	ProjectHandler.connect("path_changed",set_path)

func set_project_name(new_name:String):
	obj_project.get_node("Name").text = new_name

func color_changed():
	obj_panel.modulate = System.get_color("color_main")

func _on_path_gui_input(event):
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("left_click"):
			cancel_path()


func cancel_path():
	if ProjectHandler.current_path != ProjectHandler.project["name"]:
		emit_signal("back_path")
		ProjectHandler.path_back()
	else:
		exit_to_manager()

func set_path():
	obj_path.text = formate_path(ProjectHandler.current_path)
	
func formate_path(path:String) -> String:
	var showed_path = ""
	var list = path.split(">")
	list[0] = list[0].capitalize()
	for node in list:
		if node == list[0]:
			showed_path += node
		else:
			showed_path += " > " + ProjectHandler.project["structure"][int(node)]["name"]
	return showed_path

func change_zoom(new_zoom:float):
	new_zoom = round(new_zoom*10)/10*100
	obj_project.get_node("Zoom").text = str(new_zoom) + " %"


func exit_to_manager():
	ProjectHandler.emit_signal("quit_project")
	var save_path:String = ProjectHandler.current_project_path+"/project.dat"
	System.store_file(save_path,ProjectHandler.project)
	ProjectHandler.project = ProjectHandler.default_project
	get_tree().change_scene_to_file(path_manager)


func _on_name_gui_input(event):
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("left_click"):
			if event.double_click:
				exit_to_manager()
	
