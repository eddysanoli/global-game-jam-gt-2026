extends Control

#When the scene starts
func _ready():
	%startBtn.pressed.connect(play)
	%exitBtn.pressed.connect(quit)
	Global.garlic_basement = Vector2(0,0)
	Global.garlic_l1 = Vector2(0,0)
	Global.garlic_l2 = Vector2(0,0)	
	Global.num_people = 20
	Global.countdown = 300
	BgMusic.play()

#When play button is clicked.
func play(): 
	$ButtonSound.play()
	Engine.time_scale = 1
	await get_tree().create_timer(0.35).timeout
	get_tree().change_scene_to_file("res://scenes/Floor1/floor1.tscn")

#When exit button is clicked.
func quit(): 
	$ButtonSound.play()
	Engine.time_scale = 1
	await get_tree().create_timer(0.35).timeout
	get_tree().quit()


func _on_credits_btn_button_down() -> void:
	get_tree().change_scene_to_file("res://UI/CreditsScreen.tscn")
	


func _on_start_btn_button_down() -> void:
	if not Global.menu:
		get_tree().change_scene_to_file("res://scenes/Floor1/floor1.tscn")
	else:
		get_tree().change_scene_to_file("res://UI/IntroScreenpt1.tscn")
	
