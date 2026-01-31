extends Node2D

var garlic_scene: PackedScene = preload("res://scenes/garlic/garlic.tscn")

func _ready() -> void:
	for i in range(3): start_Garlic()

func start_Garlic():
#Variables
	var garlic = garlic_scene.instantiate() as StaticBody2D
	var pos_marker = $MarcadoresAjo.get_children().pick_random() as Marker2D
	
	#Random garlics around the scene
	garlic.position = pos_marker.position
	$Objects.add_child(garlic)

func _on_l_1_to_l_2_pressed() -> void:
	var scene_tree = get_tree()
	scene_tree.change_scene_to_file("res://scenes/Floor1/floor2.tscn")


func _on_l_1_to_b_pressed() -> void:
	var scene_tree = get_tree()
	scene_tree.change_scene_to_file("res://scenes/Basement/basement.tscn")
