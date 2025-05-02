extends Area2D
# 机关属性
@export var initial_text = "DOORCLOSED"
@export var activation_text = "OPEN"
var current_text = ""
var activated = false
var enemy_killed = false

# 用于显示文字的节点
@onready var text_label = $"../Label"

# 初始化
func _ready():
	if text_label:
		text_label.text = initial_text
	else:
		print("Error: TextLabel node not found.")
		current_text = initial_text

# 显现法术
func appear_text():
	if !activated:
		text_label.modulate = Color(1, 1, 1, 1)  # 显示文字
		current_text = initial_text
		text_label.text = current_text

# 抹除法术
func erase_text():
	if !activated and text_label.modulate.a > 0.1:
		# 随机抹除一个字符
		if current_text.length() > 1:
			var index = randi() % current_text.length()
			current_text = current_text.left(index) + current_text.right(index+1)
		else:
			current_text = ""
			
		text_label.text = current_text

# 修改法术
func modify_text(new_char):
	if !activated and text_label.modulate.a > 0.1:
		current_text = new_char
		text_label.text = current_text
		check_activation()

# 检查是否激活
func check_activation():
	if current_text == activation_text:
		activate()

# 激活机关
func activate():
	activated = true
	text_label.text = "ACTIVATED"
	text_label.modulate = Color(0, 1, 0, 1)
	
	# 消灭附近的敌人
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.position.distance_to(position) < 300:
			enemy.die()
			enemy_killed = true

# 掉落新的材料
func drop_material():
	if enemy_killed:
		@warning_ignore("shadowed_variable_base_class")
		var material = preload("res://Components/ritual_material.tscn").instantiate()
		get_parent().add_child(material)
		material.position = position + Vector2(randi_range(-50, 50), randi_range(-50, 50))
		material.set_new_character(activation_text)
		enemy_killed = false
