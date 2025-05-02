class_name Stats
extends Node

signal  health_changed
signal  energy_changed


@export var max_health: int = 3
@export var max_energy: float = 10
@export var energy_regen: float = 0.5


@onready var health: int = max_health:
	set(v):
		v = clampi(v,0,max_health)
		if health == v:
			return
		health = v
		health_changed.emit()


@onready var energy: float = max_energy:
	set(v):
		v = clampf(v,0,max_energy)
		if energy == v:
			return
		energy = v
		energy_changed.emit()

func _process(delta: float) -> void:
	energy += energy_regen * delta


func _ready() -> void:
	health_changed.emit() 
	energy_changed.emit()# 确保初始化时发出信号
