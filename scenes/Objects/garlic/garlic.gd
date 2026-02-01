extends StaticBody2D

var garlic_tables = [
	preload("res://graphics/table_1.png"),
	preload("res://graphics/table_2.png"),
	preload("res://graphics/table_3.png")
	]

func _ready() -> void:
	
	$Table.texture = garlic_tables.pick_random()
