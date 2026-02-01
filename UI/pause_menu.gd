extends Control

signal setPause(bool)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_resume_button_down() -> void:
	setPause.emit(false)

func _on_main_menu_button_down() -> void:
	get_tree().change_scene_to_file("res://UI/mainMenu.tscn")
