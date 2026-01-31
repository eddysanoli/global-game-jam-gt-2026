class_name L1toB extends Area2D



func _on_body_entered(body: Node2D) -> void:
	var scene_tree = get_tree()
	scene_tree.change_scene_to_file("res://scenes/Basement/basement.tscn") # Replace with function body.
