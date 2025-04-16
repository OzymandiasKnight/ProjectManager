extends Node2D

var node:WorkNode

func _ready():
	node.visible_notification.connect("screen_entered",hide_on_map)
	node.visible_notification.connect("screen_exited",show_on_map)
	ProjectHandler.connect("camera_moved",track_node)
	visible = true


func show_on_map():
	track_node()
	visible = true
	if node.type == "Group":
		modulate = node.color
	if node.type == "Note":
		modulate = node.color
	check_circle_visibiltiy()

func track_node():
	if node and visible:
		var angle = ProjectHandler.camera_position.angle_to_point(node.position)
		rotation = angle

func hide_on_map():
	visible = false
	check_circle_visibiltiy()

func check_circle_visibiltiy():
	get_parent().get_parent().get_parent().get_parent().check_circle_visibility()
	
