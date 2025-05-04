extends Area2D

@export var retract_time: float = 2.0  # 凸起时间（秒）
@export var spike_color: Color = Color.RED  # 尖刺的颜色
@onready var spike_timer: Timer = $"Spike timer"
@onready var passive_interacter: Passive_Interacter = $Passive_Interacter
@onready var sprite_2d: Sprite2D = $Sprite2D

var killer: Killzone

func _ready():
	spike_timer.wait_time = retract_time
	spike_timer.one_shot = true
	passive_interacter.interacted.connect(_on_interacted)
	spike_timer.timeout.connect(_on_Spike_Timer_timeout)
	
	hide_spike()

func _on_interacted():
	show_spike(spike_color)
	if killer == null:
		killer = Killzone.new()
		# 确保碰撞设置正确
		killer.set_collision_layer_value(1, true)
		killer.set_collision_mask_value(2, true)
		# 添加碰撞形状
		var shape = CollisionShape2D.new()
		shape.shape = RectangleShape2D.new()
		shape.shape.size = sprite_2d.get_rect().size
		killer.add_child(shape)
		add_child(killer)

func _on_Spike_Timer_timeout():
	hide_spike()
	if killer != null:
		killer.queue_free()
		killer = null

func show_spike(color: Color):
	if color == spike_color:
		sprite_2d.show()
		spike_timer.start()

func hide_spike():
	sprite_2d.hide()
