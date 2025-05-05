extends CharacterBody2D

enum State {
	IDLE,
	ATTACK,
	DIE,
}
@onready var event_bus: EventBus = %EventBus
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area: Area2D = $Area2D
@onready var killzone_scene: PackedScene = preload("res://Components/killzone.tscn") 

var current_state: State = State.IDLE
var player_in_range: bool = false
var active_killzone: Killzone = null

func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	sprite.animation_finished.connect(_on_animation_finished)

	sprite.play("idle")

func kill():
	event_bus.corpse_flower_killed.emit()
	queue_free()

func _process(delta):
	match current_state:
		State.IDLE:
			if player_in_range:
				transition_state(State.ATTACK)
		State.ATTACK:
			# 等待动画自动回调 _on_animation_finished
			pass
		State.DIE:
			kill()

func _on_body_entered(body):
	if body is Player:
		player_in_range = true

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

func _on_animation_finished():
	if current_state == State.ATTACK:
		# 播放完攻击动画后清除 killzone
		if active_killzone and is_instance_valid(active_killzone):
			active_killzone.queue_free()
			active_killzone = null
		# 回到 idle 状态
		transition_state(State.IDLE)

# 在攻击动画某一帧（通过 SpriteFrames 的 "帧事件"）调用
func _spawn_killzone():
	if active_killzone:  # 避免重复
		return
	active_killzone = killzone_scene.instantiate()
	add_child(active_killzone)
	active_killzone.position = Vector2(0, 0) 

#func _on_death():
	#EventBus.emit_signal("corpse_flower_killed")
	#queue_free()

