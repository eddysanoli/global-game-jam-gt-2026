extends CharacterBody2D

#Object Properties Variables
@export var speed_min: float = 30
@export var speed_max: float = 50
#Repetition Protection Variables
@export var memory_size: int = 5
@export var repeated_actions: int = 3


@onready var nav2d: NavigationAgent2D = $NavigationAgent2D
@onready var collisionRadius = $CharacterCollision.shape.radius

#Stuck Detection
var last_position: Vector2
var stuck_time := 0.0
@export var stuck_threshold := 20  
@export var min_move_distance := 2.0  

#Timers
var stand_timer := 0.0
var move_cooldown := 0.0

#Properties
var speed: float = 50
var action = ["walk", "stand", "climbStairs"]
var climbingStairs = false
var standing = false
var justMoved = false
var nearStairs = false
var nav_map: RID

#Memory Variables
var action_count = 0
var pastWaypoints: Array = []
var similarityCounter := 0
var actions = []

#Error Protection
var has_active_target := false

func _ready() -> void:
	set_physics_process(false)
	call_deferred("late_init")

func late_init():
	await get_tree().physics_frame
	nav_map = nav2d.get_navigation_map()
	last_position = global_position
	while NavigationServer2D.map_get_iteration_id(nav_map) == 0:
		await get_tree().physics_frame
	for i in range(3):
		NavigationServer2D.map_get_random_point(
			nav_map,
			0xffffffff,
			false
		)
	nav2d.target_desired_distance = 8.0
	setup()
	set_physics_process(true)


func setup():
	speed = randf_range(speed_min, speed_max)
	pickRandomPoint(global_position)
	

func _physics_process(delta):
	if not has_active_target and not standing and not justMoved:
		pickRandomPoint(global_position)
	if standing:
		stand_timer -= delta
		if stand_timer <= 0.0:
			standing = false
		return
	if justMoved:
		move_cooldown -= delta
		if move_cooldown <= 0.0:
			justMoved = false
			behaviour()
	navigate_safe()
	check_stuck(delta)

	
func navigate_safe():
	if not has_active_target:
		return
	if nav2d.is_navigation_finished():
		has_active_target = false
		justMoved = true
		move_cooldown = 2.0
		nav2d.velocity = Vector2.ZERO
		return
	if nav2d.get_current_navigation_path().is_empty():
		return
	var next_pos := nav2d.get_next_path_position()
	nav2d.velocity = global_position.direction_to(next_pos) * speed
	

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()
	

func pickRandomPoint(center: Vector2):
	for i in range(10):
		var nav_point := NavigationServer2D.map_get_random_point(
			nav_map,
			0xffffffff,
			false
		)
		if nav_point == Vector2.ZERO:
			continue
		if nav_point.distance_to(global_position) <= nav2d.target_desired_distance + collisionRadius:
			continue
		# Direction memory
		if pastWaypoints.size() > 0:
			var last = pastWaypoints.back() - center
			var current = nav_point - center
			if last.length() < 0.001 or current.length() < 0.001:
				continue
			var cosine = last.dot(current) / (last.length() * current.length())
			if cosine >= 0.75:
				similarityCounter += 1
				if similarityCounter >= 5:
					continue
			else:
				similarityCounter = 0
		if pastWaypoints.size() == memory_size:
			pastWaypoints.pop_front()
		pastWaypoints.append(nav_point)
		nav2d.target_position = nav_point
		has_active_target = true
		return



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
			pickRandomPoint(global_position)
		"stand":
			standing = true
			stand_timer = 5.0
			nav2d.velocity = Vector2.ZERO
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


func check_stuck(delta):
	var moved = global_position.distance_to(last_position)
	if moved < min_move_distance and not nav2d.is_navigation_finished():
		stuck_time += delta
	else:
		stuck_time = 0.0
	if stuck_time >= stuck_threshold:
		stuck_time = 0.0
		pickRandomPoint(global_position)
	last_position = global_position
