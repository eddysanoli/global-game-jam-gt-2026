extends Node2D

var garlic_scene: PackedScene = preload("res://scenes/garlic/garlic.tscn")

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

func _process(_delta: float):
	$Others/Control/People.text = str("There are ", Global.num_people , " people")
	if Global.num_people <= 1:
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


func _on_timer_timeout() -> void:
	Global.num_people -= 1
