extends CharacterBody2D

var speed := 20
var center = Vector2(501.0, 246.0)
var direction = (center - position)

func _physics_process(_delta):
	velocity = direction * speed
	move_and_slide()
