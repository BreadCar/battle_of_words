class_name Killzone
extends Area2D


func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		if body.has_method("kill"):
			body.kill()
