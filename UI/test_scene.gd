extends Node2D

@onready var killMenu = $KillViewnew
@onready var pauseMenu = $PauseMenu
var paused = false

	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		pause()

func pause() -> void:
	if paused:
		pauseMenu.hide()
		Engine.time_scale = 1
	else: 
		pauseMenu.show()
		Engine.time_scale = 0
	paused = !paused


func _on_monigote_monigote_clicked(node: Variant) -> void:
	print(node.name)


func _on_pause_menu_set_pause(bool: Variant) -> void:
	pause()
