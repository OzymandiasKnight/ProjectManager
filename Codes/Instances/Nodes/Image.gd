extends WorkNode

@onready var obj_texture:Sprite2D = get_node("Texture")
@onready var obj_message:Label = get_node("Message")

@export_enum("URL","PATH","SAVED") var image_type:String
var path:String = ""
var start_grab:Vector2 = Vector2(0,0)

var min_size:float = 1.0

var pre_size_factor:float = 1.0

var texture:Texture2D:
	set(new_texture):
		if obj_texture:
			if new_texture:
				obj_texture.texture = new_texture
				size = obj_texture.texture.get_size()
				set_min_size()
			else:
				
				obj_texture.texture = null
				size = custom_minimum_size
			texture = new_texture


var size_factor:float = 1.0

#Web Node
var http_request = HTTPRequest.new()

func _ready():
	super()
	texture = null
	
	#Add Web
	add_child(http_request)
	http_request.connect("request_completed", _http_request_completed)
	
	load_image()

func set_size_factor(new_size:float):
	if new_size >= 0.05 and new_size <= 2.0:
		if obj_texture.texture:
				set_min_size()
				new_size = (new_size*50)/50
				size_factor = max(new_size,min_size)
				
				obj_texture.scale = Vector2(size_factor,size_factor)
				size = obj_texture.texture.get_size()*size_factor
				
				get_parent().get_parent().obj_ui.set_node_options(self,true)

func set_min_size():
	if obj_texture:
		if obj_texture.texture:
			var min_size_y = custom_minimum_size.y/obj_texture.texture.get_size().y
			min_size_y = ceil(min_size_y*50)/50
			
			var min_size_x = custom_minimum_size.x/obj_texture.texture.get_size().x
			min_size_x = ceil(min_size_x*50)/50
			min_size = max(min_size_x,min_size_y)

func load_image():
	if path != "":
		load_from_path()
		load_from_web()
		load_from_save()
	else:
		texture = null

func set_message(message:String):
	if obj_message:
		obj_message.text = message

func load_from_web():
	if image_type == "URL":
		texture = null
		set_message("Loading Image")
		
		var error = http_request.request(path)
		
		if error != OK:
			set_message("Incorrect Link")

func _http_request_completed(result, response_code, headers, body):
	var image = Image.new()
	#Headers = Image Infos
	#Body = Data
	var informations:Array = Array(headers)
	var image_type:String = ""
	if informations:
		for info in informations:
			if info is String:
				if info.begins_with("Content-Type:"):
					if info.right(4) == "jpeg":
						image_type = "jpeg"
					elif info.right(3) == "png":
						image_type = "png"
					break
		
		if image_type != "":
			var error = null
			if image_type == "jpeg":
				error = image.load_jpg_from_buffer(body)
			elif image_type == "png":
				error = image.load_png_from_buffer(body)

			if error != OK:
				set_message("Image Error")
			else:
				retrieve_image(image)

func load_from_path():
	if image_type == "PATH":
		var image = Image.load_from_file(path)
		if image:
			set_message("")
			texture = ImageTexture.create_from_image(image)
		else:
			set_message("Incorrect Path")
			texture = null
			
		
		set_min_size()
		set_size_factor(pre_size_factor)
		pre_size_factor = -1.0

func load_from_save():
	if image_type == "SAVED":
		var image_path = ProjectHandler.current_project_path+"/images/"+path+".jpg"
		var images_list = DirAccess.open(ProjectHandler.current_project_path+"/images/").get_files()
		if path+".jpg" in images_list:
			var image:Image = Image.load_from_file(image_path) 
			if image:
				texture = ImageTexture.create_from_image(image)
				set_message("")
			else:
				texture = null
				set_message("No Image at this ID")
		else:
			texture = null
			set_message("No Image at this ID")
		set_size_factor(pre_size_factor)
		pre_size_factor = -1.0


func retrieve_image(image:Image):
	if image_type == "URL":
		var img_texture = ImageTexture.create_from_image(image)
		texture = img_texture
		set_size_factor(pre_size_factor)
		pre_size_factor = -1.0
		set_message("")


func _on_resize_gui_input(event):
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("left_click"):
			start_grab = Cursor.get_cursor_position()
		if Input.is_action_just_released("left_click"):
			print("RESIZE OOPS")
			var drag:Vector2 = (Cursor.get_cursor_position()-start_grab)/size
			if abs(drag.x)>drag.y:
				set_size_factor(size_factor + drag.x/ProjectHandler.zoom)
			else:
				set_size_factor(size_factor + drag.y/ProjectHandler.zoom)
