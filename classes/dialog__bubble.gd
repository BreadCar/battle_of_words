extends Control

@export var dialog_lines: Array[String] = []

@onready var npc_interacter: Interactable = $"../../NPC/NPC interacter"

@onready var label: Label = $NinePatchRect/Label
@onready var next_button: Button = $NextButton
@onready var event_bus: EventBus = %EventBus
@onready var player: Player = $"../../Player"

var current_index: int = 0
var char_index: int = 0
var is_typing: bool = false
var is_active: bool = false
var current_text := ""
var typing_speed := 0.03 # 每个字母的间隔秒数

func _ready():
	visible = false
	next_button.pressed.connect(_on_next_pressed)
	npc_interacter.interacted.connect(start_dialog)

func start_dialog():
	current_index = 0
	visible = true
	is_active = true
	player.controling = 2
	_show_current_line()

func _show_current_line():
	if current_index >= dialog_lines.size():
		# 对话结束
		visible = false
		is_active = false
		player.controling = -1
		return
	
	current_text = dialog_lines[current_index]
	char_index = 0
	label.text = ""
	is_typing = true
	# 开始打字
	_start_typing()

func _start_typing():
	if char_index < current_text.length():
		label.text += current_text[char_index]
		char_index += 1
		await get_tree().create_timer(typing_speed).timeout
		_start_typing()
	else:
		is_typing = false

func _on_next_pressed():
	if not is_active:
		return
	
	if is_typing:
		# 如果还在打字，直接跳到全文
		label.text = current_text
		is_typing = false
	else:
		current_index += 1
		_show_current_line()
