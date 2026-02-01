extends CharacterBody2D

# ─────────────────────────────────────────────
# Object Properties
@export var speed_min: float = 50
@export var speed_max: float = 80

# Repetition Protection
@export var memory_size: int = 5
@export var repeated_actions: int = 3

@onready var nav2d: NavigationAgent2D = $NavigationAgent2D
@onready var collisionRadius = $CharacterCollision.shape.radius

# ─────────────────────────────────────────────
# Stuck Detection
var last_position: Vector2
var stuck_time := 0.0
@export var stuck_threshold := 20
@export var min_move_distance := 2.0

# ─────────────────────────────────────────────
# Timers
var stand_timer := 0.0
var move_cooldown := 0.0

# ─────────────────────────────────────────────
# State
var speed: float
var action = ["walk", "stand", "climbStairs"]
var standing := false
var justMoved := false

# ───── Vampire / Bleeding──────────────────────
@export var is_vampire := false
@export var bite_chance := 1 
@export var bite_range := 120.0
@export var bite_distance := 80.0
@export var bite_cooldown_time := 5.0
@export var death_time := 10.0

var is_bleeding := false
var bite_target: Node2D = null
var going_to_bite := false
var bite_cooldown := 0.0

var bleed_timer := 0.0
var is_dead = false

# ─────────────────────────────────────────────
# Navigation
var nav_map: RID
var has_active_target := false

# ─────────────────────────────────────────────
# Memory
var action_count := 0
var pastWaypoints: Array = []
var similarityCounter := 0
var actions := []

# ─────────────────────────────────────────────
#  Stairs state
var nearStairs := false
var going_to_stairs := false
var active_stairs: Node2D = null


# ─────────────────────────────────────────────
func _ready() -> void:
	add_to_group("npc")
	set_physics_process(false)
	call_deferred("late_init")


func late_init():
	await get_tree().physics_frame
	nav_map = nav2d.get_navigation_map()
	last_position = global_position

	while NavigationServer2D.map_get_iteration_id(nav_map) == 0:
		await get_tree().physics_frame

	# Warm up random sampler
	for i in range(3):
		NavigationServer2D.map_get_random_point(nav_map, 0xffffffff, false)

	nav2d.target_desired_distance = 8.0
	setup()
	set_physics_process(true)


func setup():
	speed = randf_range(speed_min, speed_max)
	pickRandomPoint(global_position)


# ─────────────────────────────────────────────
func _physics_process(delta):
	# Vampire bite override
	if going_to_bite:
		process_bite()
		return
	if bite_cooldown > 0.0:
		bite_cooldown -= delta
	#Death Override
	if bleed_timer > 0.0:
		bleed_timer -= delta
	# Stairs override
	if going_to_stairs:
		navigate_safe()
		return
#	Standard Behavior
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



# ─────────────────────────────────────────────
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


# ─────────────────────────────────────────────
# Wandering
func pickRandomPoint(center: Vector2):
	for i in range(10):
		var nav_point := NavigationServer2D.map_get_random_point(
			nav_map, 0xffffffff, false
		)

		if nav_point == Vector2.ZERO:
			continue
		if nav_point.distance_to(global_position) <= nav2d.target_desired_distance + collisionRadius:
			continue

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


# ─────────────────────────────────────────────
# Behavior selection
func behaviour():
	# Vampire bite attempt
	if is_vampire and not going_to_bite and bite_cooldown <= 0.0:
		if randf() < bite_chance:
			if try_start_bite():
				return
	var random_action = action.pick_random()
	
	if bleed_timer <= 0.0 and is_bleeding == true:
		is_dead = true
		nav2d.avoidance_mask = 0
		nav2d.avoidance_enabled = false
		is_bleeding = false
	if is_dead == true:
		random_action = "stand"
		actions.pop_front()
		fading()
	if actions.size() > 0 and is_dead == false:
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
			

# ─────────────────────────────────────────────
# LOOK FOR BITE VICTIM 
func try_start_bite() -> bool:
	var candidates := []

	for npc in get_tree().get_nodes_in_group("npc"):
		if npc == self:
			continue
		if npc.is_bleeding:
			continue
		if global_position.distance_to(npc.global_position) <= bite_range:
			candidates.append(npc)
	print(candidates)
	if candidates.is_empty():
		return false
	bite_target = candidates.pick_random()
	going_to_bite = true
	has_active_target = true
	nav2d.target_position = bite_target.global_position
	return true

# ─────────────────────────────────────────────
# START PROCESS OF BITE
func process_bite():
	if bite_target == null or not is_instance_valid(bite_target):
		going_to_bite = false
		return

	nav2d.target_position = bite_target.global_position
	navigate_safe()

	if global_position.distance_to(bite_target.global_position) <= bite_distance:
		execute_bite()

# ─────────────────────────────────────────────
# BITE
func execute_bite():
	going_to_bite = false
	has_active_target = false
	nav2d.velocity = Vector2.ZERO
	print("CHOMP")
	bite_target.start_bleeding()

	bite_target = null
	justMoved = true
	move_cooldown = 3.0
	bite_cooldown = bite_cooldown_time

# ─────────────────────────────────────────────
# VICTIM STARTS BLEEDING
func start_bleeding():
	if is_bleeding:
		return

	is_bleeding = true
	bleed_timer = death_time

# ─────────────────────────────────────────────
# STAIRS NAVIGATION (NOT IMPLEMENTED YET)
func navStairs():
	if not nearStairs or active_stairs == null:
		return

	going_to_stairs = true
	standing = false
	justMoved = false

	var approach_point: Vector2 = active_stairs.get_node("ApproachPoint").global_position
	nav2d.target_position = approach_point
	has_active_target = true


# ─────────────────────────────────────────────
# CALLED BY STAIRS AREA2D (NOT IMPLEMENTED YET)
func on_stairs_entered(stairs: Node2D):
	nearStairs = true
	active_stairs = stairs

	if going_to_stairs:
		interact_with_stairs()


func on_stairs_exited(stairs: Node2D):
	if stairs == active_stairs:
		nearStairs = false


func interact_with_stairs():
	going_to_stairs = false
	has_active_target = false
	nav2d.velocity = Vector2.ZERO

	# Example scene change
	get_tree().change_scene_to_packed(active_stairs.target_scene)

# ─────────────────────────────────────────────
# Fading after death
func fading():
	pass
	queue_free()

# ─────────────────────────────────────────────
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
