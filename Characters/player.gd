class_name Player
extends CharacterBody2D
signal interacted

@onready var graphics: Node2D = $Graphics
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine
@onready var jump_request_timer: Timer = $Timers/Jump_request_timer
@onready var coyote_timer: Timer = $Timers/coyote_timer
@onready var cast_request_timer: Timer = $Timers/cast_request_timer
@onready var interaction_icon: AnimatedSprite2D = $InteractionIcon

enum State {
	IDLE,
	RUN,
	JUMP,
	FALL,
	CASTING,
	DYING,
}

const Ground_State := [State.IDLE, State.RUN]
const Player_Speed: float = 300
const Jump_Velocity: float = -300
const Accleration: float = Player_Speed / 0.2

var gravity: float = ProjectSettings.get("physics/2d/default_gravity") 

var interacting_with: Array[Interactable] = []


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump_request_timer.start()

	if event.is_action_pressed("cast"):
		cast_request_timer.start()
	if event.is_action_pressed("interact") and not interacting_with.is_empty():
		interacting_with.back().interact()  # interact 对应 F 键


func tick_physics(state: State, delta: float) -> void:
	interaction_icon.visible = not interacting_with.is_empty()
	
	match state:
		State.IDLE, State.RUN, State.JUMP, State.FALL:
			move(delta)

func move(delta: float) -> void:
	var direction: int = Input.get_axis("move_l", "move_r")
	velocity.x = move_toward(velocity.x, Player_Speed * direction, Accleration * delta)
	velocity.y += gravity * delta
	if not is_zero_approx(direction):
		graphics.scale.x = -1 if direction < 0 else 1
	move_and_slide()

func stand(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, Accleration * delta)
	velocity.y += gravity * delta
	move_and_slide()

func die() -> void:
	get_tree().reload_current_scene()

func register_interactable(v: Interactable) -> void:
	if state_machine.current_state == State.DYING:
		return
	if v in interacting_with:
		return
	interacting_with.append(v)

func unregister_interactable(v: Interactable) -> void:
	interacting_with.erase(v)

func get_next_state(state: State) -> int:
	var direction: int = Input.get_axis("move_l", "move_r")
	var is_still: bool = is_zero_approx(direction) and is_zero_approx(velocity.x)
	var can_jump: bool = coyote_timer.time_left > 0 or is_on_floor()
	var should_jump: bool = can_jump and jump_request_timer.time_left > 0
	var can_cast: bool = state in Ground_State

	var should_cast: bool = can_cast and cast_request_timer.time_left > 0


	if state in Ground_State and not is_on_floor():
		return State.FALL

	match state:
		State.IDLE:
			if not is_still:
				return State.RUN
			if should_jump:
				return State.JUMP
		State.RUN:
			if is_still:
				return State.IDLE
			if should_jump:
				return State.JUMP
		State.JUMP:
			if velocity.y >= 0:
				return State.FALL
		State.FALL:
			if is_on_floor() and is_still:
				return State.IDLE
			elif is_on_floor():
				return State.RUN
			if should_jump:
				return State.JUMP

	return StateMachine.KEEP_CURRENT

func transition_state(from: State, to: State) -> void:
	print("[%s] %s => %s" % [
		Engine.get_physics_frames(),
		State.keys()[from] if from != -1 else "<start>",
		State.keys()[to],
	])

	if from not in Ground_State and to in Ground_State:
		coyote_timer.stop()

	match to:
		State.IDLE:
			if not animation_player.is_playing() or animation_player.current_animation != "idle":
				animation_player.play("idle")
		State.RUN:
			animation_player.play("run")
		State.JUMP:
			animation_player.play("jump")
			velocity.y = Jump_Velocity
			coyote_timer.stop()
			jump_request_timer.stop()
		State.FALL:
			animation_player.play("fall")
			if from in Ground_State:
				coyote_timer.start()
