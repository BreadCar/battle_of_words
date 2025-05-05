extends Area2D

@export var next_scene_path: String  # 设置要跳转的场景路径
@export var transition_node_path: NodePath = "/root/FadeTransition"  # 脚本中调用的过渡节点路径

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is Player:
		var fade_node = get_node_or_null(transition_node_path)
		if fade_node:
			fade_node.fade_to_scene(next_scene_path)
		else:
			print("FadeTransition 节点未找到，直接切换")
			get_tree().change_scene_to_file(next_scene_path)
