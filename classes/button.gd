extends Button

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://world.tscn")

func _on_button_2_pressed() -> void:
	get_tree().quit()
