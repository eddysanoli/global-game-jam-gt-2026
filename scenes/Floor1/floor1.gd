extends Node2D

#Variables
var garlic_scene: PackedScene = preload("res://scenes/Objects/garlic/garlic.tscn")
var mins: int
var sec: int
@onready var killMenu = $KillView
@onready var pauseMenu = $PauseMenu
var paused = false
@onready var npcScn = preload("res://scenes/entities/npc.tscn")
var mask = [
	preload("res://graphics/mask_1.png"),
	preload("res://graphics/mask_2.png"),
	preload("res://graphics/mask_3.png"),
	preload("res://graphics/mask_4.png"),
	preload("res://graphics/mask_5.png")
	
	]
var faces = [
	preload("res://graphics/portrait_1.png")
	]
var vampireId;
var vampireNumber;
var rng = RandomNumberGenerator.new()
@export var monigoteScn: PackedScene = preload("res://UI/Tests/Monigote.tscn");
@export var monigoteCount: int = 10;
@export var spawnLimitsY = 720
@export var spawnLimitsX = 1080



#Scene start
func _ready() -> void:
	vampireNumber = (randi() % monigoteCount)
	start_Garlic()
	instantiateNpcs()
	

func instantiateNpcs() -> void: 
	for i in range(monigoteCount):
		var monigote = npcScn.instantiate() as NPC
		Global.person[monigote.get_instance_id()] = {"mask_image":mask.pick_random(), 
			"person_image":faces.pick_random()}
		print(Global.person, "\n")
		print('vamp number', vampireNumber)
		if i == vampireNumber:
			vampireId = monigote
			monigote.is_vampire = true
		monigote.position = Vector2(randf_range(0, spawnLimitsX), randf_range(0, spawnLimitsY))
		monigote.monigoteClicked.connect(_on_npc_clicked)
		add_child(monigote)



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

func _on_npc_clicked(node: Variant) -> void:
	print(node.name)
	killMenu.setKillerName(node);
	killMenu.show()


func _on_kill_view_cancel() -> void:
	killMenu.hide()

func _on_kill_view_kill_monigote(selectedMonigote: Variant) -> void:
	if selectedMonigote == vampireId :
		print('yaaaaayyy')
