extends Node2D

@onready var killMenu = $KillView
@onready var pauseMenu = $PauseMenu
var paused = false

@export var monigoteScn: PackedScene = preload("res://UI/Tests/Monigote.tscn");
@export var monigoteCount: int = 5;
@export var spawnLimitsY = 720
@export var spawnLimitsX = 1080
var vampireId;
var vampireNumber;
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	vampireNumber = (randi() % monigoteCount) + 1
	instantiateMonigotes()
	pass # Replace with function body.



func instantiateMonigotes() -> void:
	for i in range(monigoteCount):
		var monigote = monigoteScn.instantiate() as Monigote
		print('vamp number', vampireNumber)
		if i == vampireNumber:
			vampireId = monigote
		monigote.position = Vector2(randf_range(0, spawnLimitsX), randf_range(0, spawnLimitsY))
		print(monigote.position)
		monigote.monigoteClicked.connect(_on_monigote_monigote_clicked)
		add_child(monigote)
	
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
	killMenu.setKillerName(node);
	killMenu.show()

func _on_pause_menu_set_pause(_bool: Variant) -> void:
	pause()

func _on_kill_view_cancel() -> void:
	killMenu.hide()


func _on_kill_view_kill_monigote(selectedMonigote: Variant) -> void:
	if selectedMonigote == vampireId :
		print('yaaaaayyy')
