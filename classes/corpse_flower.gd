extends CharacterBody2D

enum State {
	IDLE,
	ATTACK,
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var area: Area2D = $Area2D  # 添加感应区域节点并拖到这里

var current_state: State = State.IDLE
var player_in_range := false

func _ready():
	area.connect("body_entered", _on_body_entered)
	area.connect("body_exited", _on_body_exited)

func _process(delta):
	var new_state = get_next_state()
	if new_state != current_state:
		transition_state(current_state, new_state)
		current_state = new_state

func get_next_state() -> State:
	if player_in_range:
		return State.ATTACK
	return State.IDLE

func transition_state(from: State, to: State) -> void:
	match to:
		State.IDLE:
			anim.play("idle")
		State.ATTACK:
			anim.play("attack")


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false
