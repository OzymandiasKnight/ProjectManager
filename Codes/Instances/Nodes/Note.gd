extends WorkNode

@export var text:String = ""
@export var color:Color = Color.WHITE:
	set(new_color):
		modulate = new_color
		color = new_color

@onready var obj_text:TextEdit = get_node("Text")
@onready var obj_preview:Panel = get_node("Preview")

var last_drag:Vector2 = Vector2(0,0)
var b_preview:Vector2 = size

var adjusting:String = ""

var font_size:int = 18:
	set(new_size):
		font_size = new_size
		obj_text["theme_override_font_sizes/font_size"] = new_size

func _ready():
	super()
	font_size = font_size
	color = color
	obj_text.text = text
	obj_preview.size = size
	b_preview = size
	obj_preview.position = Vector2(0,0)

func set_typing():
	obj_text.grab_focus()
	var caret_position:Vector2i = Vector2i(0,0)
	caret_position.y = int(obj_text.get_line_count())
	caret_position.x = len(obj_text.get_line(caret_position.y-1))
	obj_text.set_caret_column(caret_position.x)
	obj_text.set_caret_line(caret_position.y)
	#obj_text.set_cursor_position()


#Text Input #Escape Button
func _on_text_gui_input(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("escape"):
			if obj_text.has_focus():
				obj_text.release_focus()
				text = obj_text.text

#Inputs Drag Size
func _input(event):
	if event is InputEventMouseButton:
		if Input.is_action_just_released("left_click"):
			if adjusting != "":

				var new_size = get_new_size()
				
				add_size(new_size[0],new_size[1])

				adjusting = ""
	elif event is InputEventMouseMotion:
		
		var new_size = get_new_size()
		add_size(new_size[0],new_size[1],true)

func get_new_size() -> Array:
	var drag:Vector2 = (last_drag-Cursor.get_cursor_position())
	#Adjust Window
	
	var d_size:Vector2 = Vector2(0,0)
	var d_pos:Vector2 = Vector2(0,0)
	
	if adjusting == "Top":
		d_size = Vector2(0,drag.y)
		d_pos = Vector2(0,drag.y)
	elif adjusting == "Bot":
		d_size = Vector2(0,-drag.y)
		d_pos = Vector2(0,0)
	elif adjusting == "Left":
		d_size = Vector2(drag.x,0)
		d_pos = Vector2(drag.x,0)
	elif adjusting == "Right":
		d_size = Vector2(-drag.x, 0)
		d_pos = Vector2(0,0)
	return [d_size,d_pos]

func add_size(new_size:Vector2,new_pos:Vector2,preview:bool=false):
	if preview:
		obj_preview.position -= new_pos
		obj_preview.size = b_preview + new_size
	else:
		position -= new_pos
		size += new_size
		obj_preview.size = size
		obj_preview.position = Vector2(0,0)

func start_adjusting():
	last_drag = Cursor.get_cursor_position()
	b_preview = size
	obj_text.release_focus()

func _on_top_gui_input(event):
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("left_click"):
			adjusting = "Top"
			start_adjusting()

func _on_bottom_gui_input(event):
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("left_click"):
			adjusting = "Bot"
			start_adjusting()


func _on_left_gui_input(event):
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("left_click"):
			adjusting = "Left"
			start_adjusting()

func _on_right_gui_input(event):
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("left_click"):
			adjusting = "Right"
			start_adjusting()
