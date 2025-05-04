extends Node2D

@export var retract_time: float = 2.0  # 凸起时间（秒）
@export var spike_color: Color = Color.RED  # 尖刺的颜色
@onready var spike_timer = $Spike_Timer

func _ready():
	spike_timer.wait_time = retract_time
	spike_timer.one_shot = true
	hide_spike()

func _on_Spike_Timer_timeout():
	hide_spike() 


func show_spike(color: Color):
	if color == spike_color:
		$Sprite2D.show()
		spike_timer.start()  # 开始计时

# 隐藏尖刺
func hide_spike():
	spike.visible = false
	await get_tree().create_timer(2.0).timeout
	spike.visible = true
