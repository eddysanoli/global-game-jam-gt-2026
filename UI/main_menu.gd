extends Control

func _ready():
	%startBtn.pressed.connect(play)
	%exitBtn.pressed.connect(quit)
	Global.num_people = 20
	BgMusic.play()

func play(): 
	Global.countdown = 10
	get_tree().change_scene_to_file("res://scenes/Floor1/floor1.tscn")
	Engine.time_scale = 1


func quit(): 
	get_tree().quit()
