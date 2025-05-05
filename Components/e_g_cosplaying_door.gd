extends Label



@onready var container: VBoxContainer = $"../WordBoard/Container"


func _ready() -> void:
	container.door_open.connect(_on_interacted)
	
func _on_interacted() -> void:
	text = "我是门，我开了"
