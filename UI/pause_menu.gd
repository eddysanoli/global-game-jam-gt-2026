extends Control

signal setPause(bool)


func _on_resume_button_down() -> void:
	$QuitPause.play()
	Engine.time_scale = 1
	await get_tree().create_timer(0.1).timeout
	BgMusic.play(Global.music_time)
	BgMusic.play(Global.music_time)
	setPause.emit(false)

func _on_main_menu_button_down() -> void:
	var scene_tree = get_tree()
	$QuitPause.play()
	Engine.time_scale = 1
	await get_tree().create_timer(0.2).timeout
	scene_tree.change_scene_to_file("res://UI/mainMenu.tscn")
