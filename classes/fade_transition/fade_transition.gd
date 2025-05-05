extends CanvasLayer

@export var fade_duration: float = 0.5  # 淡入淡出动画的持续时间（秒）

@onready var fade_overlay: ColorRect = $FadeOverlay

var _tween: Tween

func _ready() -> void:
	if fade_overlay:
		fade_overlay.modulate.a = 0.0

# 播放淡入淡出动画
func fade_to_scene(scene_path: String) -> void:
	if not fade_overlay:
		push_warning("FadeOverlay 未找到，直接切换场景")
		get_tree().change_scene_to_file(scene_path)
		return

	if is_instance_valid(_tween) and _tween.is_running():
		_tween.stop()
		_tween.kill()

	_tween = create_tween()
	# 淡出（变黑）
	_tween.tween_property(fade_overlay, "modulate:a", 1.0, fade_duration)
	# 切换场景
	_tween.tween_callback(func():
		get_tree().change_scene_to_file(scene_path)
		
	)
	# 淡入（变亮）
	_tween.tween_property(fade_overlay, "modulate:a", 0.0, fade_duration)
