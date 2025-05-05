extends Control
@export var main_menu_scene_path: String = "res://Scenes/Start_Page/start_page.tscn"
@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer

func _ready():
	video_player.play()
	video_player.finished.connect(_on_video_finished)

func _on_video_finished():
	get_tree().change_scene_to_file(main_menu_scene_path)
