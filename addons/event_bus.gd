class_name EventBus
extends Node

# Platform Control Signals
signal platform_control_started(direction: Vector2)
signal platform_control_ended()

signal player_control_locked()
signal player_control_unlocked()
signal slime_killed # 史莱姆类型参数
signal corpse_flower_killed

var kill_counters = {
	"slime": 0,
	"corpse_flower": 0
}


# Layer Constants
enum Layer {
	PLAYER = 1,
	ENEMY = 2, 
	PLATFORM = 3,
	OBSTACLE = 4
}

static func get_instance() -> EventBus:
	return Engine.get_main_loop().root.get_node("EventBus") as EventBus
