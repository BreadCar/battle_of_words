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
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var event_bus: EventBus = %EventBus

enum State {
	IDLE,
	RUN,
	JUMP,
	FALL,
	CASTING,
	DYING,
	CONTROLING_PLATFORM,
}

var player_skills: Dictionary = {
	"edit": true,
	"up": false,
	"down": false,
	"left": false,
	"right": false,
	"true": false,
	"false": false
}

const Ground_State := [State.IDLE, State.RUN]
const Player_Speed: float = 300
const Jump_Velocity: float = -300
const Accleration: float = Player_Speed / 0.2

var gravity: float = ProjectSettings.get("physics/2d/default_gravity") 

var interacting_with: Array[Interactable] = []

var killed: bool = false

var controling: int = -1

var slime_kill_counter: int = 0
var corpse_flower_kill_counter: int = 0

func _ready():

	pass
	#EventBus.connect("slime_killed",_on_slime_killed)
	#EventBus.connect("slime_unlocked",_on_skill_unlocked)
	#EventBus.connect("corpse_flower_killed", _on_corpse_flower_killed)

#func _on_slime_killed(type: String):
	#EventBus.kill_counters.slime += 1
	#match  EventBus.kill_counters.slime:
		#1:
			#EventBus.player_skills.manifest.up = true
			#EventBus.emit_signal("skill_unlocked", "manifest", "up")
		#2:
			#EventBus.player_skills.manifest.down = true
			#EventBus.emit_signal("skill_unlocked", "manifest", "down")
		#3:
			#EventBus.player_skills.manifest.left = true
			#EventBus.emit_signal("skill_unlocked", "manifest", "left")
		#4:
			#EventBus.player_skills.manifest.right = true
			#EventBus.emit_signal("skill_unlocked", "manifest", "right")

#func corpse_flower_killed():
	#EventBus.kill_counters.corpse_flower+=1
	#match EventBus.kill_counters.corpse_flower:
		#1:
			#EventBus.player_skills.clear.true = true
			#EventBus.emit_signal("skill_unlocked", "erase", "true")
		#2:
			#EventBus.player_skills.clear.false = true
			#EventBus.emit_signal("skill_unlocked", "erase", "false")

func _on_skill_unlocked(skill_type: String, ability_name: String):
	match skill_type:
		"manifest":
			print("解锁显现·%s 能力" % ability_name)
			_enable_direction_ability(ability_name)
		"erase":
			print("解锁抹除·%s 能力" % ability_name)
			_enable_logic_ability(ability_name)
		"modify":
			print("解锁抹除·%s 能力" % ability_name)
			_enable_logic_ability(ability_name)

func _enable_direction_ability(dir: String):
	match dir:
		"up":
			$UpIndicator.visible = true
		"down":
			$DownIndicator.visible = true
		"left":
			$LeftIndicator.visible = true
		"right":
			$RightIndicator.visible = true

func _enable_logic_ability(logic: String):
	# 实现逻辑能力的具体效果 
	match logic:
		"true":
			$TrueParticles.emitting = true
		"false":
			$FalseParticles.emitting = true

func _physics_process(delta):
	pass
	# 检查终极技能解锁条件
	#if (EventBus.kill_counters.slime >= 4 && 
		#EventBus.kill_counters.corpse_flower >= 2 &&
		#!EventBus.player_skills.modify):
		
		#EventBus.player_skills.modify = true
		#EventBus.emit_signal("skill_unlocked", "modify", "")
			 

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump_request_timer.start()
	if event.is_action_pressed("interact") and interacting_with:
		var interacted = interacting_with.back()
		interacted.interact()
		if interacting_with.back() is Platform_Interacter:
			print("[DEBUG] Interact input - controling before: ", controling)
			match controling:
				-1:  # 直接设置为1表示开始控制
					controling = 1
					print("[DEBUG] Platform interact - controling set to: ", controling)
				1:
					controling = -1
					print("[DEBUG] Platform interact - controling set to: ", controling)

func kill() -> void:
	if not killed:  # 防止重复触发
		killed = true
		print("Player killed")

func die() -> void:
	# 延迟一帧再重载场景，避免同一帧内重复触发
	await get_tree().process_frame
	get_tree().reload_current_scene()

func tick_physics(state: State, delta: float) -> void:
	interaction_icon.visible = not interacting_with.is_empty()
	
	match state:
		State.IDLE, State.RUN, State.JUMP, State.FALL:
			move(delta)
			
		State.RUN:
			move(delta)
		
		State.JUMP:
			move(delta)
			
		State.FALL:
			move(delta)
		
		State.DYING:
			stand(delta)
		
		State.CONTROLING_PLATFORM:
			# 控制平台时玩家自身不移动
			velocity = Vector2.ZERO
			move_and_slide()

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



func register_interactable(v: Interactable) -> void:
	if state_machine.current_state == State.DYING:
		return
	if v in interacting_with:
		return
	interacting_with.append(v)

func unregister_interactable(v: Interactable) -> void:
	interacting_with.erase(v)

func get_next_state(state: State) -> int:
	# 如果已经是DYING状态则保持不变
	if state == State.DYING:
		return StateMachine.KEEP_CURRENT
		
	var direction: int = Input.get_axis("move_l","move_r")
	var is_still: bool = is_zero_approx(direction) and is_zero_approx(velocity.x)
	var can_jump: bool = coyote_timer.time_left > 0 or is_on_floor()
	var should_jump: bool = can_jump and jump_request_timer.time_left > 0
	var can_cast: bool = state in Ground_State

	var should_cast: bool = can_cast and cast_request_timer.time_left > 0


	if state in Ground_State and not is_on_floor():
		return State.FALL
	if killed and state != State.DYING:  # 只在非DYING状态时转换到DYING
		return State.DYING
	
	match state:
		State.IDLE:
			if not is_still:
				return State.RUN
			if should_jump:
				return State.JUMP
			if not interacting_with.is_empty() and controling == 1:
				print("[DEBUG] State transition to CONTROLING_PLATFORM")
				return State.CONTROLING_PLATFORM
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
		
		State.DYING:
			# 确保只执行一次死亡逻辑
			if not killed:
				killed = true
				print("Player entering DYING state")
				die()
			return StateMachine.KEEP_CURRENT
		
		State.CONTROLING_PLATFORM:
			if controling != 1:  # 只要不是1就退出控制状态
				print("[DEBUG] Exiting CONTROLING_PLATFORM state, controling: ", controling)
				return State.IDLE
			
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
		
		State.DYING:
			animation_player.play("hurt")
			velocity.y = Jump_Velocity / 2
			collision_shape_2d.disabled = true
			
		State.CONTROLING_PLATFORM:
			animation_player.play("controling")
