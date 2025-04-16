extends GridContainer

@export var safe_margin:float = 0.0
@export var item_size:float = 1.0

func _ready():
	get_tree().root.connect("size_changed",display_resolution_changed)
	display_resolution_changed()

func display_resolution_changed():
	var display_size:float = get_parent().size.x
	#Godot add a 2pixels margin between grid items
	var ratio:float = (display_size-safe_margin)/(item_size+2)
	columns = floor(ratio)
