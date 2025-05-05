class_name EventBus
extends Node

# Platform Control Signals
signal platform_control_started(direction: Vector2)
signal platform_control_ended()
signal player_control_locked()
signal player_control_unlocked()

# Layer Constants
enum Layer {
	PLAYER = 1,
	ENEMY = 2, 
	PLATFORM = 3,
	OBSTACLE = 4
}

static func get_instance() -> EventBus:
	return Engine.get_main_loop().root.get_node("EventBus") as EventBus
