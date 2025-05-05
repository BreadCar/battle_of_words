extends Node2D

func _ready():
    $UI/Button_Panel/Button/StartButton.pressed.connect(_on_start_button_pressed)
    $UI/Button_Panel/Button/OptionButton.pressed.connect(_on_option_button_pressed)
    $UI/Button_Panel/Button/ExitButton.pressed.connect(_on_exit_button_pressed)

func _on_start_button_pressed():
    get_tree().change_scene_to("res://Game.tscn")

func _on_option_button_pressed():
   get_tree().change_scene_to("res://Options.tscn")
 
func _on_exit_button_pressed():
    get_tree().quit()

func _on_node_enter_tree():
    # 可以添加动画
    pass

func _on_node_exit_tree():
    pass
