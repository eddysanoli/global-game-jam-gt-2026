extends Control

signal setPause(bool)

func _on_resume_button_down() -> void:
	setPause.emit(false)

func _on_main_menu_button_down() -> void:
	var scene_tree = get_tree()
	scene_tree.change_scene_to_file("res://UI/mainMenu.tscn")
