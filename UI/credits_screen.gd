extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func back() -> void:
	get_tree().change_scene_to_file("res://UI/mainMenu.tscn")


func _on_button_button_down() -> void:
	back()
