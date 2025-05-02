extends CharacterBody2D

var MoveSpeed = 150
var Velocity = Vector2.ZERO

func _physics_process(delta):
    velocity.x = MoveSpeed
    if position.x > 500:
        velocity.x = -MoveSpeed
    elif position.x < -500:
        velocity.x = MoveSpeed
        
    move_and_slide()

func die():
    queue_free()
