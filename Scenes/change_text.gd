extends Node2D

@onready var label = $Label  
var current_text = "真" 

func _ready():
	var area2d = get_parent().get_node("Area2D")
	area2d.connect("interact_pressed",self,"change_text")

func change_text():
	if current_text == "真":
		current_text = "假"
	else:
		current_text = "真"
	label.text = current_text  
