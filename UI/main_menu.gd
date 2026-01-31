extends Control

func _ready():
	%startBtn.pressed.connect(play)
	%exitBtn.pressed.connect(quit)
	Global.num_people = 20

func play(): 
	get_tree().change_scene_to_file("res://scenes/Floor1/floor1.tscn")
	Global.countdown = 300
	
	
func quit(): 
	get_tree().quit()
