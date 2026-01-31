extends Control

func _ready():
	%startBtn.pressed.connect(play)
	%exitBtn.pressed.connect(quit)

func play(): 
	get_tree().change_scene_to_file("res://UI/testScene.tscn")
	
	
func quit(): 
	get_tree().quit()
