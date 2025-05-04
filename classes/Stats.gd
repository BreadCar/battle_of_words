class_name Stats
extends Node

signal  health_changed


@export var max_health: int = 3


@onready var health: int = max_health:
	set(v):
		v = clampi(v,0,max_health)
		if health == v:
			return
		health = v
		health_changed.emit()

func _ready() -> void:
	health_changed.emit() # 确保初始化时发出信号
