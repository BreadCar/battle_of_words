class_name Platform
extends CharacterBody2D

@onready var interact_point: Interactable = $"../Interact_point"
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var event_bus: EventBus = %EventBus

var current_direction: Vector2 = Vector2.ZERO
var move_speed: float = 100.0
var is_controlled: bool = false
var is_waiting_for_input: bool = false

func _ready():
	interact_point.interacted.connect(_on_interacted)
	# Set collision layers through Project Settings
	collision_layer = 1 << 0 | 1 << 1  # Layer 1 (World) and Layer 2 (Player)
	collision_mask = 1 << 0 | 1 << 1   # Collide with World and Player
	
	# Connect to existing EventBus node
	event_bus.connect("platform_control_started", _on_platform_control_started)
	event_bus.connect("platform_control_ended", _on_platform_control_ended)

func _on_interacted():
	if is_controlled:
		event_bus.emit_signal("platform_control_ended")
		event_bus.emit_signal("player_control_unlocked")
	else:
		is_waiting_for_input = true
		event_bus.emit_signal("player_control_locked")

func _input(event):
	if is_controlled and current_direction == Vector2.ZERO:
		if event.is_action_pressed("move_l"):
			current_direction = Vector2.LEFT
		elif event.is_action_pressed("move_r"):
			current_direction = Vector2.RIGHT
		elif event.is_action_pressed("move_up"):
			current_direction = Vector2.UP
		elif event.is_action_pressed("move_dn"):
			current_direction = Vector2.DOWN
	elif is_waiting_for_input:
		if event.is_action_pressed("move_l"):
			is_waiting_for_input = false
			current_direction = Vector2.LEFT
			event_bus.emit_signal("platform_control_started", current_direction)
		elif event.is_action_pressed("move_r"):
			is_waiting_for_input = false
			current_direction = Vector2.RIGHT
			event_bus.emit_signal("platform_control_started", current_direction)

func _physics_process(delta):
	if is_controlled and current_direction != Vector2.ZERO:
		var velocity = current_direction * move_speed
		var collision = move_and_collide(velocity * delta)
		
		if collision:
			# 检查碰撞对象是否是玩家
			if collision.get_collider() is Player:
				# 将玩家推开避免卡住
				var push_vector = velocity.normalized() * 10
				collision.get_collider().velocity += push_vector
			current_direction = Vector2.ZERO  # 停止移动但保持控制状态

func _on_platform_control_started(direction: Vector2):
	current_direction = direction
	is_controlled = true

func _on_platform_control_ended():
	is_controlled = false
	is_waiting_for_input = false
	current_direction = Vector2.ZERO
	event_bus.emit_signal("player_control_unlocked")
