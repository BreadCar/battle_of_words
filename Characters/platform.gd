extends StaticBody2D

@export var platform_color: Color = Color.RED  # 平台的颜色
@export var speed: float = 200.0  # 平台移动速度
var velocity = Vector2.ZERO
var can_control: bool = false

func _physics_process(delta):
    if can_control:
        # 获取输入
        var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
        velocity = input_vector * speed
        # 移动平台
        move_and_slide(velocity)

# 显示平台
func show_platform():
    $Sprite2D.show()

# 隐藏平台
func hide_platform():
    $Sprite2D.hide()
