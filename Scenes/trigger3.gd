extends Area2D

signal interact_pressed

func _input(event):
    if event is InputEventKey and event.pressed and event.scancode == KEY_F:
        emit_signal("interact_pressed")  
