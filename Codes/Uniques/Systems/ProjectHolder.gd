extends Node2D

var node_group = preload("res://Scenes/Instances/Nodes/Group.tscn")
var node_note = preload("res://Scenes/Instances/Nodes/Note.tscn")
var node_image = preload("res://Scenes/Instances/Nodes/Image.tscn")

@onready var obj_camera:Camera2D = get_node("Camera")
@onready var obj_nodes:Node = get_node("Nodes")
@onready var obj_ui:CanvasLayer = get_node("UI")
@onready var obj_background:CanvasLayer = get_node("Background")
@onready var obj_background_pattern:TextureRect = obj_background.get_node("Pattern")

var moving_node:WorkNode = null

var current_structure:Dictionary = {}

var project_loaded:bool = false

func _ready():
	System.connect("color_changed",color_changed)
	color_changed()
	obj_ui.set_project_name(ProjectHandler.project_name)
	obj_ui.visible = true
	obj_background.visible = true
	get_viewport().files_dropped.connect(on_files_dropped)
	ProjectHandler.connect("path_changed",load_structure)
	ProjectHandler.connect("path_changing",save_structure)
	ProjectHandler.connect("quit_project",save_structure)
	
	#UI Signals
	obj_ui.obj_add.connect("add_node",add_node)
	
	load_structure()


func color_changed():
	obj_background.get_node("Color").modulate = System.get_color("color_background")
	obj_background_pattern.modulate = System.get_color("color_secondary")

func _physics_process(delta):
	var arrow_move:Vector2 = Vector2(0,0)
	if Input.is_action_pressed("left_arrow"):
		arrow_move.x -= 1
	if Input.is_action_pressed("right_arrow"):
		arrow_move.x += 1
	if Input.is_action_pressed("up_arrow"):
		arrow_move.y -= 1
	if Input.is_action_pressed("down_arrow"):
		arrow_move.y += 1
	obj_camera.position += arrow_move*15
	ProjectHandler.camera_position = obj_camera.position

func _input(event):
	#In tests
	
	if event is InputEventKey:
		if false:
			if Input.is_action_just_pressed("escape"):
				if obj_ui.obj_options.edited_node == null:
					obj_ui.obj_path.cancel_path()
			

				
		if Input.is_action_just_pressed("paste"):
			if obj_ui.obj_options.edited_node == null:
				var pasted_image:Image = DisplayServer.clipboard_get_image()
				if pasted_image:
					
					var image_name:String = ProjectHandler.get_new_image_id()
					ProjectHandler.save_image(pasted_image,image_name)
					paste_picture(image_name)
		
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("middle_click"):
			obj_camera.position -= event.relative
			ProjectHandler.camera_position = obj_camera.position
		if moving_node:
			moving_node.modulate.a = 0.75
			moving_node.global_position += event.relative/obj_camera.zoom

	if event is InputEventMouseButton:
		if Input.is_action_just_released("left_click"):
			if moving_node:
				#var condition:bool =  (Cursor.hovered_group==null and (Cursor.hovered_group.id != moving_node.id) and moving_node.type != "Group")
				
				if false:#condition:
					var new_path = []
					if ProjectHandler.project["structure"].has(moving_node.id):
						new_path = ProjectHandler.project["structure"][moving_node.id]["path"]
						new_path.append(str(Cursor.hovered_group.id))
						ProjectHandler.project["structure"][moving_node.id]["path"] = new_path
					else:
						var create_path:Array = ProjectHandler.current_path.split(">")
						create_path.append(str(Cursor.hovered_group.id))
						ProjectHandler.project["structure"][moving_node.id] = ProjectHandler.get_structure_from_node(moving_node)
						ProjectHandler.project["structure"][moving_node.id]["path"] = create_path

					moving_node.delete()
					moving_node = null
					Cursor.hovered_group = null
				else:
					moving_node.modulate.a = 1.0
					moving_node = null
		
		var zoom_change:Vector2 = Vector2(0,0)
		
		var incrementation:float = 0.05
		
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_change = Vector2(-incrementation,-incrementation)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_change = Vector2(incrementation,incrementation)
			
		var new_zoom = (obj_camera.zoom+zoom_change).clamp(Vector2(0.2,0.2),Vector2(2.0,2.0))
		ProjectHandler.zoom = new_zoom.x
		obj_camera.zoom = new_zoom
		obj_ui.obj_path.change_zoom(obj_camera.zoom.x)

func load_structure():
	obj_camera.position = ProjectHandler.project["camera_position"]
	ProjectHandler.camera_position = obj_camera.position
	obj_camera.zoom = ProjectHandler.project["camera_zoom"]
	
	obj_ui.reset_pointers()
	
	for node in obj_nodes.get_children():
		if node is WorkNode:
			node.queue_free()
	var project_structure:Dictionary = ProjectHandler.project["structure"]
	for id in project_structure.keys():
		if project_structure[id]["path"] == Array(ProjectHandler.current_path.split(">")):
			var node:WorkNode = WorkNode.new()
			node.node_name = project_structure[id]["name"]
			node.type = project_structure[id]["type"]
			node.id = id
			var custom_parameter:Dictionary = {}
			#Group custom Parameters
			if node.type == "Group":
				#Color
				if project_structure[id].has("color"):
					custom_parameter["color"] = project_structure[id]["color"]
				if project_structure[id].has("icon"):
					custom_parameter["icon"] = project_structure[id]["icon"]
			#Note custom Parameters
			if node.type == "Note":
				#Text
				if project_structure[id].has("text"):
					custom_parameter["text"] = project_structure[id]["text"]
				if project_structure[id].has("size"):
					custom_parameter["size"] = project_structure[id]["size"]
				if project_structure[id].has("color"):
					custom_parameter["color"] = project_structure[id]["color"]
			if node.type == "Image":
				#Image
				if project_structure[id].has("image_type"):
					custom_parameter["image_type"] = project_structure[id]["image_type"]
				if project_structure[id].has("image_path"):
					custom_parameter["image_path"] = project_structure[id]["image_path"]
				if project_structure[id].has("size"):
					custom_parameter["size"] = project_structure[id]["size"]
				if project_structure[id].has("size_factor"):
					custom_parameter["size_factor"] = project_structure[id]["size_factor"]
			
			add_node(node,project_structure[id]["position"],custom_parameter)
	moving_node = null
	obj_ui.obj_options.set_edited_node(null)

func save_structure():
	ProjectHandler.project["camera_position"] = obj_camera.position
	ProjectHandler.project["camera_zoom"] = obj_camera.zoom
	var project_structure:Dictionary = ProjectHandler.project["structure"]
	var default_nodes:Array[int] = []
	#Get path as array
	var path = Array(ProjectHandler.current_path.split(">"))
	#Get Work nodes ids existing before changes
	for id in project_structure.keys():
		if project_structure[id]["path"] == path:
			default_nodes.append(id)
	
	#Get current Work nodes
	var scene_nodes:Array[int] = []
	for node in obj_nodes.get_children():
		if node is WorkNode:
			scene_nodes.append(node.id)
			save_node(node)
			
	#Check for deleted Work Nodes
	for def_id in default_nodes:
		if not def_id in scene_nodes:
			for id in project_structure.keys():
				#Delete every Work nodes in the deleted Work node
				if str(def_id) in project_structure[id]["path"]:
					ProjectHandler.project["structure"].erase(id)
			ProjectHandler.project["structure"].erase(def_id)

func save_node(node):
	ProjectHandler.project["structure"][node.id] = ProjectHandler.get_structure_from_node(node)

func on_files_dropped(file):
	var dropped:Array = Array(file)
	for pictures in dropped:
		if pictures.ends_with(".jpg") or pictures.ends_with(".png"):
			drop_picture(pictures)

func drop_picture(path:String):
	var new_node:WorkNode = WorkNode.new()
	var image_name:String = path.split('\\')[len(path.split('\\'))-1]
	if image_name.ends_with(".jpg"):
		image_name = image_name.left(-4)
	if image_name.ends_with(".png"):
		image_name = image_name.left(-4)
	new_node.node_name = image_name
	new_node.type = "Image"
	var options:Dictionary = {
		"image_type": "PATH",
		"image_path": path,
	}
	add_node(new_node,obj_camera.position,options)

func paste_picture(pic_name:String):
	var new_node:WorkNode = WorkNode.new()
	new_node.node_name = pic_name
	new_node.type = "Image"
	var options:Dictionary = {
		"image_type": "SAVED",
		"image_path": pic_name,
	}
	add_node(new_node,obj_camera.position,options)

func add_node(node:WorkNode,node_position:Vector2,options={}):
	var new_node:WorkNode = WorkNode.new()
	if node.type == "Group":
		new_node = node_group.instantiate()
	if node.type == "Note":
		new_node = node_note.instantiate()
	if node.type == "Image":
		new_node = node_image.instantiate()
	
	new_node.node_name = node.node_name
	new_node.global_position = node_position-Vector2(50,50)
	new_node.id = node.id
	
	#Group Related
	if new_node.type == "Group":
		if options.has("color"):
			new_node.color = options["color"]
		if options.has("icon"):
			new_node.icon = options["icon"]
	#Note Related
	if new_node.type == "Note":
		if options.has("text"):
			new_node.text = options["text"]
		if options.has("size"):
			new_node.size = options["size"]
		if options.has("color"):
			new_node.color = options["color"]
	
	
	if new_node.type == "Image":
		if options.has("image_type"):
			new_node.image_type = options["image_type"]
		if options.has("image_path"):
			new_node.path = options["image_path"]
		if options.has("size"):
			new_node.size = options["size"]
		if options.has("size_factor"):
			new_node.pre_size_factor = options["size_factor"]
	
	obj_nodes.add_child(new_node)
	obj_ui.add_pointer(new_node)



func use_node(node:WorkNode):
	if node.type == "Group":
		ProjectHandler.path_next(node.id)
	elif node.type == "Note":
		node.set_typing()
	if node.type == "Image":
		pass
