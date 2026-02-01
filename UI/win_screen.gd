extends Control


func _on_button_button_down() -> void:
	get_tree().change_scene_to_file("res://UI/mainMenu.tscn")

func _ready() -> void:
	BgMusic.stop()
	get_tree().create_timer(0.8).timeout
	$Win.play()
