extends Enemy

enum State{
	IDLE,
	WALK,
	RUN,
	ATTACK,
	HURT,
	DIE,
}

var speed: float = 100

@onready var wall_checker: RayCast2D = $Graphics/Wall_checker
@onready var edge_checker: RayCast2D = $Graphics/edge_checker
@onready var player_checker: RayCast2D = $Graphics/Player_checker
@onready var colddown_timer: Timer = $Timers/colddown_timer
@onready var slime_dead_sound = $SlimeDeadSound
@onready var slime_attack_sound = $SlimeAttackSound
@onready var event_bus: EventBus = %EventBus
@onready var killzone: Killzone = $Graphics/Killzone

func can_see_player() -> bool:
	if not player_checker.is_colliding():
		return false
	else:
		return player_checker.get_collider() is Player

func enable_killzone() -> void:
	killzone.monitoring = true

func disable_killzone() -> void:
	killzone.monitoring = false

func tick_physics(state: State, delta: float) -> void:
	
	var should_turn = (wall_checker.is_colliding() and not wall_checker.get_collider() is Player) or not edge_checker.is_colliding()
	if should_turn:
		direction *= -1
	
	match state:
		State.IDLE,State.ATTACK,State.HURT,State.DIE:
			move(0.0 , delta)
		State.RUN:
			move(speed , delta)
			if can_see_player():
				colddown_timer.start()
		State.WALK:
			move(speed / 3 , delta)

func get_next_state(state: State) -> int:
	
	var direction: int = Input.get_axis("move_l","move_r")
	var should_attack: bool = wall_checker.is_colliding() and wall_checker.get_collider() is Player
	if stats.health == 0:
		return State.DIE
	
	match state:
		State.IDLE:
			if state_machine.state_time > 2:
				return State.RUN
			if can_see_player():
				return State.RUN
		State.WALK:
			if state_machine.state_time > 8:
				return State.IDLE
			if can_see_player():
				return State.RUN
		State.RUN:
			if should_attack:
				return State.ATTACK
			if not can_see_player() and colddown_timer.is_stopped():
				return State.WALK
			
		State.ATTACK:
			if not should_attack:
				return State.RUN
			
		State.HURT:
			if not animation_player.is_playing():
				return State.RUN
			
		State.DIE:
			pass
	
	return StateMachine.KEEP_CURRENT
	
func transition_state(from: State , to: State) -> void:
	
	match to:
		State.IDLE:
			animation_player.play("idle")
		State.RUN:
			animation_player.play("run")
		State.WALK:
			animation_player.play("run")
		State.ATTACK:
			animation_player.play("attack")
			slime_attack_sound.play()
		State.HURT:
			animation_player.play("hurt")
		State.DIE:
			animation_player.play("die")
			slime_dead_sound.play()
func _on_death():
	event_bus.emit_signal("slime_killed")
	queue_free()
