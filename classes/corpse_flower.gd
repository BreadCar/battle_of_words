extends CharacterBody2D

enum State {
	IDLE,
	ATTACK,
	DYING,
}

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area: Area2D = $Area2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var killzone_scene: PackedScene = preload("res://Components/killzone.tscn") 

var current_state: State = State.IDLE
var player_in_range: bool = false
var active_killzone: Killzone = null
var killed: bool = false
var gravity: float = ProjectSettings.get("physics/2d/default_gravity")

func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.play("idle")

func _physics_process(delta):
	velocity.y += gravity * delta
	move_and_slide()
	if current_state == State.DYING:
		velocity.y += gravity * delta
		move_and_slide()
		if position.y > get_viewport_rect().size.y + 100:
			queue_free()
		return

	match current_state:
		State.IDLE:
			if player_in_range:
				transition_state(State.ATTACK)
		State.ATTACK:
			pass

func _on_body_entered(body):
	if body is Player:
		player_in_range = true
	elif body is Killzone:
		kill()

func _on_body_exited(body):
	if body is Player:
		player_in_range = false

func transition_state(to: State):
	current_state = to
	match to:
		State.IDLE:
			sprite.play("idle")
		State.ATTACK:
			sprite.play("attack")
		State.DYING:
			sprite.play("die")
			velocity.y = -300
			collision_shape.disabled = true

func _on_animation_finished():
	if current_state == State.ATTACK:
		if active_killzone and is_instance_valid(active_killzone):
			active_killzone.queue_free()
			active_killzone = null
		transition_state(State.IDLE)

func _spawn_killzone():
	if active_killzone:
		return
	active_killzone = killzone_scene.instantiate()
	add_child(active_killzone)
	active_killzone.position = Vector2(0, 0)

func kill():
	if not killed:
		killed = true
		transition_state(State.DYING)
