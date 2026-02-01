extends Node2D

#Variables
var garlic_scene: PackedScene = preload("res://scenes/Objects/garlic/garlic.tscn")
var mins: int
var sec: int
@onready var killMenu = $KillViewnew
@onready var pauseMenu = $PauseMenu
var paused = false



#Scene start
func _ready() -> void:
	start_Garlic()



#Game finishes if the time is up or the amount of people is <= 1
func _process(_delta: float) -> void:
	$Others/Control/People.text = str("There are ", Global.num_people , " people alive")
	mins = snapped(Global.countdown / 60.0,0)
	sec = Global.countdown - (mins*60)
	$Others/Control/Minutes.text = str("0", mins)
	if sec < 10:
		$Others/Control/Seconds.text = str("0", sec)
	else:
		$Others/Control/Seconds.text = str(sec)
	
	if Global.num_people <= 1 or Global.countdown <= 0:
		_on_main_menu_pressed("res://UI/FailMenu.tscn")



#Set the garlic in a random place, but stays in the position during the game
func start_Garlic():
	var garlic = garlic_scene.instantiate() as StaticBody2D
	var pos_marker = $MarcadoresAjo.get_children().pick_random() as Marker2D
	if Global.garlic_l1.is_zero_approx():
		Global.garlic_l1 = pos_marker.position
	else:
		pos_marker.position = Global.garlic_l1
	garlic.position = pos_marker.position
	$Objects.add_child(garlic)



#Buttons on this level
func _on_l_1_to_l_2_pressed() -> void:
	var scene_tree = get_tree()
	scene_tree.change_scene_to_file("res://scenes/Floor2/floor2.tscn")

func _on_l_1_to_b_pressed() -> void:
	var scene_tree = get_tree()
	scene_tree.change_scene_to_file("res://scenes/Basement/basement.tscn")

func _on_main_menu_pressed(tex = "res://UI/mainMenu.tscn") -> void:
	var scene_tree = get_tree()
	$Others/ButtonSound.play()
	Engine.time_scale = 1
	await get_tree().create_timer(0.35).timeout
	scene_tree.change_scene_to_file(tex)



#The game is paused when ESC is pressed.
func _on_pause_menu_set_pause(_bool: Variant) -> void:
	pause()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		Global.music_time = BgMusic.get_playback_position()
		if BgMusic.playing:
			BgMusic.stop()
			$Others/EnterPause.play()
		else:
			Engine.time_scale = 1
			$Others/QuitPause.play()
			await get_tree().create_timer(0.3).timeout
			BgMusic.play(Global.music_time)
		pause()

func pause() -> void:
	if paused:
		pauseMenu.hide()
		Engine.time_scale = 1
	else: 
		pauseMenu.show()
		Engine.time_scale = 0
	paused = !paused



#Timer
func _on_timer_timeout() -> void:
	Global.countdown -= 1
