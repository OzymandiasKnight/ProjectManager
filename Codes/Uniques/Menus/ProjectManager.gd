extends Node2D

var pre_project_card = preload("res://Scenes/Instances/Interface/Project.tscn")

const menu_manager:String = "res://Scenes/Uniques/Menus/ProjectHolder.tscn"

const path_user:String = "user://"
const path_manager:String = "user://projects/"

@onready var obj_screen:CanvasLayer = get_node("Screen")
@onready var obj_window:Control = obj_screen.get_node("Window")
@onready var obj_top_band:Control = obj_window.get_node("TopBand")
@onready var obj_project_grid:GridContainer = obj_window.get_node("Scroll/Grid")
@onready var obj_search_bar:LineEdit = obj_top_band.get_node("Searchbar")
@onready var obj_background:ColorRect = obj_window.get_node("Background")
@onready var obj_project_creation:Control = obj_window.get_node("ProjectCreation")
@onready var obj_project_modification:Control = obj_window.get_node("ProjectModification")
@onready var obj_project_modification_panel:Panel = obj_project_modification.get_node("Project/Panel")
@onready var obj_project_modif_name:LineEdit = obj_project_modification.get_node("Project/ProjectName")
@onready var obj_project_creation_panel:Panel = obj_project_creation.get_node("Project/Panel")
@onready var obj_splash_screen:AnimationPlayer = obj_window.get_node("SplashScreen/Animation")

var project_name:String=""
var modifying_project:String = ""

func _ready():
	System.connect("color_changed",color_changed)
	color_changed()
	load_projects_list()
	obj_project_modification.visible = false
	if ProjectHandler.splash_screen:
		obj_splash_screen.play("Load")
		ProjectHandler.splash_screen = false

func color_changed():
	obj_background.color = System.get_color("color_background")
	obj_project_creation_panel.self_modulate = System.get_color("color_main")
	obj_project_modification_panel.self_modulate = System.get_color("color_main")

func load_projects_list():
	for project in obj_project_grid.get_children():
		project.queue_free()
	# Standard
	var dir:DirAccess = DirAccess.open(path_manager)
	if dir:
		var project_directories:Array = dir.get_directories()
		for project in project_directories:
			obj_project_grid.add_child(load_project_informations(project))
	else:
		dir = DirAccess.open(path_user)
		dir.make_dir_absolute(path_manager)
		load_projects_list()

func load_project_informations(project_name:String) -> Control:
	var dir = DirAccess.open(path_manager+project_name+"/")
	var files_names:Array = Array(dir.get_files())
	
	dir = DirAccess.open(path_manager+project_name+"/")
	var project_folders:Array = Array(dir.get_directories())
	
	if len(project_folders) == 0:
		dir.make_dir("images")

	
	var project_card:Control = pre_project_card.instantiate()
	project_card.project_name = project_name
	project_card.name = project_name
	return project_card
	

func load_project(project_name):
	if project_name != "":
		ProjectHandler.current_project_path = path_manager+project_name
		var project_path:String = path_manager+project_name+"/project.dat"
		var project:Dictionary = System.open_file(project_path,ProjectHandler.default_project)
		ProjectHandler.project_name = project_name
		ProjectHandler.project = project
		get_tree().change_scene_to_file(menu_manager)

func create_project(project_name):
	if project_name != "":
		ProjectHandler.project = ProjectHandler.default_project
		var dir = DirAccess.open(path_manager)
		dir.make_dir(project_name)
		dir = DirAccess.open(path_manager+project_name)
		dir.make_dir("images")
		

func modify_project(project_name:String):
	modifying_project = project_name
	obj_project_modification.visible = true
	obj_project_modif_name.text = project_name

func delete_project():
	if modifying_project != "":
		var dir:DirAccess = DirAccess.open(path_manager+modifying_project+"/images")
		for file in dir.get_files():
			dir.remove(file)
		dir = DirAccess.open(path_manager+modifying_project)
		dir.remove("images")
		dir.remove("project.dat")
		dir = DirAccess.open(path_manager)
		dir.remove(modifying_project)
		obj_project_modification.visible = false
		load_projects_list()

func _on_searchbar_text_changed(new_text:String):
	for project in obj_project_grid.get_children():
		if project.project_name.to_lower().begins_with(new_text.to_lower()) or new_text == "":
			project.visible = true
		else:
			project.visible = false


func _on_cancel_pressed():
	obj_project_creation.visible = false


func _on_new_project_pressed():
	obj_project_creation.visible = true


func _on_confirm_pressed():
	var project_name = obj_project_creation.get_node("Project/Name").text
	create_project(project_name)
	load_project(project_name)


func _on_refresh_pressed():
	load_projects_list()


func _on_delete_project_pressed():
	if modifying_project != "":
		delete_project()
	


func _on_project_save_pressed():
	if obj_project_modif_name.text != modifying_project:
		if obj_project_modif_name.text != "":
			var dir = DirAccess.open(path_manager)
			dir.rename(modifying_project,obj_project_modif_name.text)

	obj_project_modification.visible = false
	load_projects_list()

