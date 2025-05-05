extends VBoxContainer

signal door_open

@onready var stone_1: Interactable = $"../Stone1"
@onready var stone_2: Interactable = $"../Stone2"
@onready var label: Label = $Label

var last_stone: Interactable = null


func _ready():
	stone_1.interacted.connect(_on_stone_interacted.bind(stone_1))
	stone_2.interacted.connect(_on_stone_interacted.bind(stone_2))
	
func _on_stone_interacted(line: String, stone: Interactable) -> void:
	label.text = line
	last_stone = stone
	
	# Check if showing specific word
	if stone == stone_1 and "第二个词" in line:
		door_open.emit()
