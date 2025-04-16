extends Node

signal path_changing()
signal path_changed()
signal quit_project()
signal camera_moved()



var default_group_color:Color = Color("fbf8cc")

var default_project:Dictionary ={
	"type": "Project",
	"name": "home",
	"nodes_count": 0,
	"camera_zoom": Vector2(1.0,1.0),
	"camera_position": Vector2(0.0,0.0),
	"structure": {}
}

var project:Dictionary = {
}

var current_project_path:String = ""

var current_path:String = ""

var zoom:float = 1.0
var camera_position:Vector2 = Vector2(0,0):
	set(new_position):
		emit_signal("camera_moved")
		camera_position = new_position

var project_name:String = ""

var splash_screen:bool = true

func _ready():
	project = default_project
	current_path = project["name"]

func path_back():
	if current_path != project["name"]:
		emit_signal("path_changing")
		var new_path = current_path.split(">")
		new_path.remove_at(len(new_path)-1)
		current_path = ">".join(new_path)
		emit_signal("path_changed")

func path_next(next:int):
	emit_signal("path_changing")
	current_path = current_path + ">" + str(next)
	emit_signal("path_changed")

func get_new_image_id() -> String:
	var images_list = DirAccess.open(ProjectHandler.current_project_path+"/images/").get_files()
	var ids_list:Array = []
	for node in images_list:
		ids_list.append(int(node.left(-4)))
	var final_id:int = 0
	
	if (final_id in ids_list)==false:
		return str(final_id)
	else:
		for id in ids_list:
			if final_id != id:
				break
			else:
				final_id += 1
			
		return str(final_id)

func save_image(image:Image,pic_name):
	var images_path:String = current_project_path+"/images/" + pic_name + ".jpg"
	var dir = DirAccess.open(images_path)
	if image != null:
		if System.settings["image_compression"]:
			image.save_jpg(images_path,0.75)
		else:
			image.save_jpg(images_path,1.0)

func get_structure_from_node(node:WorkNode) -> Dictionary:
	var dict:Dictionary = {}
	dict["type"] = node.type
	dict["name"] = node.node_name
	dict["position"] = node.global_position+Vector2(50,50)
	#if project["structure"].has(node.id):
	#	if project["structure"][node.id].has("path"):
	dict["path"] = Array(current_path.split(">"))
	#Group Specific Keys
	if node.type == "Group":
		dict["color"] = node.color
		dict["icon"] = node.icon
	if node.type == "Note":
		dict["text"] = node.text
		dict["size"] = node.size
		dict["color"] = node.color
	if node.type == "Image":
		dict["image_type"] = node.image_type
		dict["image_path"] = node.path
		dict["size"] = node.size
		dict["size_factor"] = node.size_factor
		print("ProjectHandler",dict["size_factor"])
	return dict
