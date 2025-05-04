class_name NPC
extends CharacterBody2D

enum State{
	IDLE,
	INTERACTING,
}


@onready var npc_interacter: Area2D = $"NPC interacter"
@onready var lines: Label = $VBoxContainer/Lines
@onready var interact_timer: Timer = $interact_timer
@onready var state_machine: StateMachine = $StateMachine
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	pass
	npc_interacter.interacted.connect(_on_interacted)
	interact_timer.timeout.connect(_on_interact_timer_timeout)
	lines.visible = false

func _on_interacted() -> void:
	pass
	interact_timer.start()
	lines.visible = true

func _on_interact_timer_timeout() -> void:
	lines.visible = false
	
func tick_physics(state: State, delta: float) -> void:
	pass
	
func get_next_state(state: State) -> int:
	match state:
		State.IDLE:
			return State.INTERACTING if lines.visible else StateMachine.KEEP_CURRENT
		State.INTERACTING:
			return State.IDLE if not lines.visible else StateMachine.KEEP_CURRENT
	return StateMachine.KEEP_CURRENT
	
func transition_state(from: State , to: State) -> void:
	match to:
		State.IDLE:
			animation_player.play("idle")
		State.INTERACTING:
			animation_player.play("interact")
