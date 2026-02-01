extends Control

func _on_button_button_down() -> void:
	Global.menu = true
	get_tree().change_scene_to_file("res://scenes/Floor1/floor1.tscn")
