class_name Platform
extends Area2D

@onready var interact_point: Interactable = $"../Interact_point"
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var activate: bool = false
var is_moving: bool = false
var move_direction: Vector2 = Vector2.ZERO
var move_speed: float = 100.0
var velocity: Vector2 = Vector2.ZERO

func _ready():
	interact_point.interacted.connect(_on_interacted)

func _on_interacted():
	print("Platform activated")
	if is_moving:
		# Stop movement if currently moving
		is_moving = false
		activate = false
		velocity = Vector2.ZERO
	else:
		# Get direction input and start moving
		var direction_x = Input.get_axis("move_l", "move_r")
		var direction_y = 0
		
		if direction_x == 0:  # Only check vertical if no horizontal input
			direction_y = Input.get_axis("move_up", "move_down")
		
		if direction_x != 0 or direction_y != 0:
			move_direction = Vector2(direction_x, direction_y).normalized()
			is_moving = true
			activate = true
			velocity = move_direction * move_speed

func _physics_process(delta):
	if is_moving:
		position += velocity * delta
		
		# Check for collisions using test_move
		var params = PhysicsTestMotionParameters2D.new()
		params.from = position
		params.motion = velocity * delta
		
		var result = PhysicsServer2D.body_test_motion(
			get_rid(),
			params
		)
		
		if result:
			is_moving = false
			move_direction = Vector2.ZERO
			velocity = Vector2.ZERO
