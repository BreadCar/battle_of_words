extends Button

@export var next_scene_path: String
@export var transition_node_path: NodePath = "/root/FadeTransition"  # 全局单例或主场景中 FadeTransition 的路径

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	var fade_node = get_node_or_null(transition_node_path)
	if fade_node:
		fade_node.fade_to_scene(next_scene_path)
	else:
		print("FadeTransition 节点未找到，直接切换")
		get_tree().change_scene_to_file(next_scene_path)
