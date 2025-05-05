extends Sprite2D

@onready var killzone: Area2D = $Killzone
@onready var interact_point: Interactable = $"../Interact_point"
@onready var collision_shape_2d_2: CollisionShape2D = $"../../Scene/Edge/CollisionShape2D2"


func _ready():
	interact_point.interacted.connect(_on_interacted)

func _on_interacted():
	# 方法一：直接隐藏
	visible = false
	killzone.visible = false
	killzone.set_deferred("monitoring", false) # 禁用碰撞检测
	collision_shape_2d_2.queue_free()
	# 方法二：也可以直接 queue_free 删除节点
	# sprite.queue_free()
	# killzone.queue_free()
