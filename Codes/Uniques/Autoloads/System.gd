extends Node

signal color_changed()

var default_settings:Dictionary = {
	"relative_speed": true,
	"image_compression": true,
	"color_main": Color("3a506b"),
	"color_secondary": Color("1c2541"),
	"color_background": Color("0b132b")
}

var settings:Dictionary = {
	
}

var main_color:Color

var path_settings:String = "user://settings.dat"

func _ready():
	DisplayServer.window_set_min_size(Vector2(1024,600))
	#Settings
	settings = default_settings
	settings = open_file(path_settings,default_settings)
	set_color("color_main",settings["color_main"])
	set_color("color_secondary",settings["color_secondary"])
	set_color("color_background",settings["color_background"])
	# Create an HTTP Node

func set_color(priority:String,color:Color):
	settings[priority] = color
	
	save_settings()
	emit_signal("color_changed")

func get_color(priority:String) -> Color:
	if settings.has(priority):
		return settings[priority]
	else:
		return Color.BLACK


func save_settings():
	store_file(path_settings,settings)

#-- -- File Manipulation -- --

#Open File
func open_file(path:String,default:Dictionary):
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path,FileAccess.READ)
		var content:Dictionary = file.get_var()
		file.close()
		return content
	else:
		store_file(path,default)
		return default

#Store File
func store_file(path:String,content:Dictionary):
	#repair_directory(path)
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_var(content)
		file.close()

#Repair broken directory
func repair_directory(path:String):
	var path_size:int = len(path.split("/"))
	if path_size > 3:
		var separation:Array = path.split("/")
		var folder:String = separation[-1]
		if folder != "":
			var checking:String = path.left(-len(folder)-1)
			DirAccess.make_dir_recursive_absolute(checking)
