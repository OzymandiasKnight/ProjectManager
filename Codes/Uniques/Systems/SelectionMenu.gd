extends Control

@onready var obj_types:Control = get_node("Types")
@onready var obj_name:LineEdit = get_node("NodeName/Edit")
@onready var obj_group:Control = obj_types.get_node("Group")
@onready var obj_color_choices:GridContainer = obj_group.get_node("Color/Choices")
@onready var obj_icon_choices:GridContainer = obj_group.get_node("Icon/Icons")

@onready var obj_note:Control = obj_types.get_node("Note")

@onready var obj_font_size:SpinBox = obj_note.get_node("Size/FontSize")

@onready var obj_image:Control = obj_types.get_node("Image")
@onready var obj_image_size:HSlider = obj_image.get_node("ImageSize")
@onready var obj_image_path:LineEdit = obj_image.get_node("ImagePath")
@onready var obj_image_id:SpinBox = obj_image.get_node("ImageID")
@onready var obj_image_scale:Label = obj_image.get_node("Scale")
@onready var obj_image_type:OptionButton = obj_image.get_node("ImageType")
@onready var obj_image_delete:Button = obj_image.get_node("DeleteImage")
@onready var obj_image_download:Button = obj_image.get_node("DownloadImage")

var edited_node:WorkNode = null

func _ready():
	ProjectHandler.connect("path_changing",reset_edited_node)

func _input(event):
	if visible:
		if event is InputEventKey:
			if Input.is_action_just_pressed("backspace"):
				if not obj_name.has_focus():
					
					if edited_node.type == "Note":
						if not edited_node.obj_text.has_focus() and not obj_font_size:
							delete_node()
					elif edited_node.type == "Image":
						if not obj_image_path.has_focus():
							delete_node()
					else:
						delete_node()
					

			if Input.is_action_just_pressed("escape"):
				if not obj_name.has_focus():
					if edited_node.type == "Note":
						if not edited_node.obj_text.has_focus():
							set_edited_node(null)
					else:
						set_edited_node(null)

func set_edited_node(new_node:WorkNode,update=false):
	if new_node:
		if new_node == edited_node and update == false:
			visible = false
			#Set null
			reset_edited_node()
		else:
			visible = true
			if edited_node:
				edited_node.unmodify()
			#Set New
			edited_node = new_node
			set_node_options(edited_node)
	else:
		visible = false
		#Set null
		reset_edited_node()
	
	get_parent().get_parent().show_option_menu(visible)

func set_node_options(node:WorkNode):
	obj_name.text = node.node_name
	for type in obj_types.get_children():
		type.visible = false

	if obj_types.has_node(node.type):
		obj_types.get_node(node.type).visible = true
	
	image_paramters_actualise(node)
	
	

func _on_edit_text_submitted(new_text):
	if edited_node:
		edited_node.node_name = new_text
		obj_name.release_focus()

func set_color(color:Color):
	if edited_node:
		if edited_node.type == "Group":
			edited_node.color = color
			for node in obj_icon_choices.get_children():
				node.set_color(color)
		if edited_node.type == "Note":
			edited_node.color = color

func set_icon(icon:String):
	if edited_node:
		if edited_node.type == "Group":
			edited_node.icon = icon

func _on_button_pressed():
	delete_node()

func delete_node():
	if edited_node:
		edited_node.delete()
		set_edited_node(null)

func reset_edited_node():
	if edited_node:
		edited_node.unmodify()
	edited_node = null
	for type in obj_types.get_children():
		type.visible = false



func _on_font_size_value_changed(value):
	if edited_node:
		if edited_node.type == "Note":
			edited_node.font_size = int(value)


func _on_image_size_value_changed(value):
	if edited_node:
		if edited_node.type == "Image":
			if edited_node.pre_size_factor == -1.0:
				edited_node.set_size_factor(value)
				obj_image_scale.text = "Scale : x" + str(value)
			
			if edited_node.texture == null:
				obj_image_size.min_value = 0.1
				obj_image_size.value = 1.0
				obj_image_size.max_value = 2.0


func _on_image_path_text_submitted(new_text):
	if edited_node:
		if edited_node.type == "Image":
			if edited_node.image_type == "PATH" or edited_node.image_type == "URL":
				edited_node.path = new_text
				edited_node.load_image()
				obj_image_path.release_focus()


func _on_image_type_item_selected(index):
	if edited_node:
		if edited_node.type == "Image":
			if index == 0:
				edited_node.image_type = "URL"
				obj_image_delete.visible = false
				obj_image_path.placeholder_text = "URL"
				obj_image_path.visible = true
			elif index == 1:
				edited_node.image_type = "PATH"
				obj_image_delete.visible = false
				obj_image_path.placeholder_text = "Path"
				obj_image_path.visible = true
			else:
				edited_node.image_type = "SAVED"
				obj_image_delete.visible = true
				obj_image_path.visible = false
				obj_image_id.value = 0
				
			obj_image_id.visible = !obj_image_path.visible
			obj_image_download.visible = !obj_image_delete.visible
			
			edited_node.load_image()


func _on_delete_image_pressed():
	if edited_node:
		if edited_node.type == "Image":
			if edited_node.image_type == "SAVED":
				var dir = DirAccess.open(ProjectHandler.current_project_path+"/images/")
				dir.remove(edited_node.path+".jpg")
				edited_node.path = ""
				obj_image_path.text = ""
				edited_node.load_image()


func _on_download_image_pressed():
	if edited_node:
		if edited_node.type == "Image":
			if edited_node.image_type in ["PATH","URL"]:
				if edited_node.texture:
					var image_name:String = ProjectHandler.get_new_image_id()
					var image:Image = edited_node.texture.get_image()
					if image:
						ProjectHandler.save_image(image,image_name)
						obj_image_type.selected = 2


func _on_image_id_value_changed(value):
		if edited_node:
			if edited_node.type == "Image":
				if edited_node.image_type == "SAVED":
					var dir = DirAccess.open(ProjectHandler.current_project_path+"/images/")
					
					var max_id:int = -1
					for file in dir.get_files():
						if file.ends_with(".jpg"):
							max_id += 1
					obj_image_id.max_value = max_id
					edited_node.path = str(value)
					edited_node.load_image()
					obj_image_id.release_focus()

func image_paramters_actualise(node:WorkNode,index:float=-1):
	if node.type == "Group":
		set_color(node.color)
	if node.type == "Note":
		obj_font_size.value = node.font_size
	if node.type == "Image":
		obj_image_size.min_value = node.min_size
		obj_image_size.value = node.size_factor
		obj_image_scale.text = "Scale : x" + str(node.size_factor)
		if node.image_type == "URL":
			obj_image_type.selected = 0
			obj_image_delete.visible = false
			obj_image_path.text = node.path
			obj_image_path.visible = true
			
		elif node.image_type == "PATH":
			obj_image_type.selected = 1
			obj_image_delete.visible = false
			obj_image_path.text = node.path
			obj_image_path.visible = true
			
		else:
			obj_image_type.selected = 2
			obj_image_delete.visible = true
			obj_image_id.value = int(node.path)
			obj_image_path.visible = false

		obj_image_id.visible = !obj_image_path.visible
		obj_image_download.visible = !obj_image_delete.visible
