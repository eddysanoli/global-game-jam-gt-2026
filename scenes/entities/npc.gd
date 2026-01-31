extends CharacterBody2D

@export var speed_min: float = 40
@export var speed_max: float = 80
@export var memory_size: int = 5

@onready var nav2d: NavigationAgent2D = $NavigationAgent2D
@onready var collisionRadius = $CharacterCollision.shape.radius
@onready var navArea = $MovementArea.shape.radius

var speed: float = 50
var pastWaypoints: Array = []
var similarityCounter := 0

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
	navigate_safe()
	
func manual_navigation():
	if Input.is_action_just_pressed("set_target"):
		nav2d.target_position = get_global_mouse_position()
		print(get_global_mouse_position())
	
func navigate():
	if nav2d.is_navigation_finished():
		pickRandomPoint(global_position, collisionRadius, navArea)
	var next_path_position: Vector2 = nav2d.get_next_path_position()
	velocity = (global_position.direction_to(next_path_position)* speed)
#	Rotar sprite aqui
	move_and_slide()
	
func navigate_safe():
	if nav2d.is_navigation_finished():
		pickRandomPoint(global_position, collisionRadius, navArea)
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
		if pastWaypoints.size() == 5:
			pastWaypoints.pop_front()
		var last_Waypoint = pastWaypoints.back()
		var cosene = last_Waypoint.dot(new_target)/(last_Waypoint.length() * new_target.length())
		if cosene >= 0.75:
			similarityCounter += 1
			if similarityCounter == 5:
				print("triggered")
				if angle < PI:
					angle = randf_range(PI, TAU)
				angle = randf_range(0, PI)
				new_target = ((vec*dist).rotated(angle) + center)
				cosene = last_Waypoint.dot(new_target)/(last_Waypoint.length() * new_target.length())
	pastWaypoints.append(new_target)
	print(pastWaypoints)
	nav2d.target_position = new_target
