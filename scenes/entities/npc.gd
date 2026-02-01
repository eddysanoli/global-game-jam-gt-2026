extends CharacterBody2D

@export var speed_min: float = 40
@export var speed_max: float = 80
@export var memory_size: int = 5
@export var repeated_actions: int = 3

@onready var nav2d: NavigationAgent2D = $NavigationAgent2D
@onready var collisionRadius = $CharacterCollision.shape.radius
@onready var navArea = $MovementArea.shape.radius

var action_count = 0
var speed: float = 50
var pastWaypoints: Array = []
var similarityCounter := 0
var actions = []
var nearStairs = false
var action = ["walk", "stand", "climbStairs"]
var climbingStairs = false
var standing = false

func _ready() -> void:
	set_physics_process(false)
	setup()
	call_deferred("late_init")

func late_init():
	set_physics_process(true)

func setup():
	speed = randf_range(speed_min, speed_max)
	pickRandomPoint(global_position, collisionRadius, navArea)
	

func _physics_process(_delta):
	manual_navigation()
	if standing == true:
		await get_tree().create_timer(3).timeout
		standing = false
	navigate_safe()
	
func manual_navigation():
	if Input.is_action_just_pressed("set_target"):
		nav2d.target_position = get_global_mouse_position()
		print(get_global_mouse_position())
	
func navigate():
	if nav2d.is_navigation_finished():
		await get_tree().create_timer(3).timeout
		behaviour()
	var next_path_position: Vector2 = nav2d.get_next_path_position()
	velocity = (global_position.direction_to(next_path_position)* speed)
#	Rotar sprite aqui
	move_and_slide()
	
func navigate_safe():
	if nav2d.is_navigation_finished():
		if climbingStairs == true:
			climbingStairs = false
			move_floor()
		behaviour()
	var next_path_position: Vector2 = nav2d.get_next_path_position()
	var new_velocity: Vector2 = (global_position.direction_to(next_path_position)* speed)
	nav2d.velocity = new_velocity
	
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()
	
func pickRandomPoint(center: Vector2, inner: float, outer: float):
	var angle: float = randf_range(0.0, TAU)
	var vec: Vector2 = Vector2.RIGHT
	var dist: float = randf_range(inner, outer)
	var new_target = ((vec*dist).rotated(angle) + center)
	if pastWaypoints.size() != 0:
		if pastWaypoints.size() == memory_size:
			pastWaypoints.pop_front()
		var last_Waypoint = pastWaypoints.back()
		var cosene = last_Waypoint.dot(new_target)/(last_Waypoint.length() * new_target.length())
		if cosene >= 0.75:
			similarityCounter += 1
			if similarityCounter == 5:
				if angle < PI:
					angle = randf_range(PI, TAU)
				angle = randf_range(0, PI)
				new_target = ((vec*dist).rotated(angle) + center)
				cosene = last_Waypoint.dot(new_target)/(last_Waypoint.length() * new_target.length())
	pastWaypoints.append(new_target)
	nav2d.target_position = new_target
	
func behaviour():
	var random_action = action.pick_random()
	if actions.size() != 0:
		if actions.back() == "climbStairs":
			random_action = "walk"
		for element in actions:
			if element == random_action:
				action_count += 1
				if action_count == 3 and random_action == "stand":
					random_action = "walk"
					action_count = 0
		if actions.size() == repeated_actions:
			actions.pop_front()
	actions.append(random_action)
	
	match random_action:
		"walk":
			pickRandomPoint(global_position, collisionRadius, navArea)
		"stand":
			standing = true
		"climbStairs":
			navStairs()


func navStairs():
	if nearStairs == true:
		climbingStairs = true
		var new_target = $"../../Stairs".global_position
		nav2d.target_position = new_target
		navigate_safe()
		
func move_floor():
	pass
