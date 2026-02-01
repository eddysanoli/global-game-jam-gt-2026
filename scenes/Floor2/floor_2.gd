extends Node2D

var garlic_scene: PackedScene = preload("res://scenes/garlic/garlic.tscn")
var mins: int
var sec: int
@onready var killMenu = $KillViewnew
@onready var pauseMenu = $PauseMenu
var paused = false

func _ready() -> void:
	start_Garlic()

func start_Garlic():
	#Variables
	var garlic = garlic_scene.instantiate() as StaticBody2D
	var pos_marker = $MarcadoresAjo.get_children().pick_random() as Marker2D
	if Global.garlic_l2.is_zero_approx():
		Global.garlic_l2 = pos_marker.position
	else:
		pos_marker.position = Global.garlic_l2
			
	#Random garlics around the scene
	garlic.position = pos_marker.position
	$Objects.add_child(garlic)

func _process(_delta: float) -> void:
	$Others/Control/People.text = str("There are ", Global.num_people , " people alive")
	mins = snapped(Global.countdown / 60,0)
	sec = Global.countdown - (mins*60)
	$Others/Control/Minutes.text = str("0", mins)
	if sec < 10:
		$Others/Control/Seconds.text = str("0", sec)
	else:
		$Others/Control/Seconds.text = str(sec)
	
	if Global.num_people <= 1 or Global.countdown <= 0:
		_on_main_menu_pressed("res://UI/FailMenu.tscn")

func _on_l_2_to_b_pressed() -> void:
	var scene_tree = get_tree()
	scene_tree.change_scene_to_file("res://scenes/Basement/basement.tscn")


func _on_l_2_to_l_1_pressed() -> void:
	var scene_tree = get_tree()
	scene_tree.change_scene_to_file("res://scenes/Floor1/floor1.tscn")


func _on_main_menu_pressed(tex = "res://UI/mainMenu.tscn") -> void:
	var scene_tree = get_tree()
	scene_tree.change_scene_to_file(tex)
	Global.garlic_basement = Vector2(0,0)
	Global.garlic_l1 = Vector2(0,0)
	Global.garlic_l2 = Vector2(0,0)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		pause()

func _on_timer_timeout() -> void:
	Global.countdown -= 1
	

func pause() -> void:
	if paused:
		pauseMenu.hide()
		Engine.time_scale = 1
	else: 
		pauseMenu.show()
		Engine.time_scale = 0
	paused = !paused


func _on_pause_menu_set_pause(bool: Variant) -> void:
	pause()
