class_name Enemy
extends CharacterBody2D

enum Direction {
	LEFT = -1,
	RIGHT  = 1,
}

@export var direction := Direction.LEFT:
	set(v):
		direction = v
		if not is_node_ready():
			await ready
		graphics.scale.x = -direction

@export var max_speed : float = 180
@export var Acceleration : float = 2000

var default_gravity := ProjectSettings.get("physics/2d/default_gravity") as float

@onready var stats: Stats = $Stats
@onready var graphics: Node2D = $Graphics
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: Node = $StateMachine

func move(speed:float,delta:float):
	velocity.x  = move_toward( velocity.x , speed * direction , Acceleration * delta )
	velocity.y += default_gravity * delta
	move_and_slide()
	
func die() -> void:
	queue_free()
