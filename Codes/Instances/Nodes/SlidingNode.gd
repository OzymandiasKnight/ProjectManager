extends Control

func _ready():
	get_node("Node/Panel/Name").text = name

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("left_click"):
			get_node("Animation").play("Select")
			var new_node:WorkNode = WorkNode.new()
			new_node.type = name
			new_node.node_name = new_node.type
			ProjectHandler.project["nodes_count"] = ProjectHandler.project["nodes_count"] + 1
			new_node.id = ProjectHandler.project["nodes_count"]

			get_parent().get_parent().get_parent().set_sliding(new_node)
