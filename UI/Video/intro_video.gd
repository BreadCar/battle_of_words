extends Control

@export var next_scene_path: String = "res://Scenes/Game_play/00_Tutorial.tscn"
@export var transition_node_path: NodePath = "/root/FadeTransition" 
@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer

func _ready():
	# 连接结束信号
	video_player.finished.connect(_on_video_finished)

func _on_video_finished():
	get_tree().change_scene_to_file(next_scene_path)
