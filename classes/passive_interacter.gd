class_name Passive_Interacter
extends Area2D

signal interacted

func _ready() -> void:
	collision_layer = 0
	collision_mask = 0
	set_collision_mask_value(2, true)
	body_entered.connect(_on_body_entered)

func interact(player: Player) -> void:
	if player.state_machine.current_state != player.State.DYING:
		interacted.emit()

func _on_body_entered(player: Player) -> void:
	if player is Player:
		interact(player)
