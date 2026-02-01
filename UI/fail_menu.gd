extends Control


func _on_button_pressed() -> void:
	$ButtonSound.play()
	Engine.time_scale = 1
	await get_tree().create_timer(0.35).timeout
	get_tree().change_scene_to_file("res://UI/mainMenu.tscn")
