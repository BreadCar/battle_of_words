extends CharacterBody2D

const RunSpeed:=300
const Floor_Accleration=RunSpeed/0.2
const Air_Accleration=RunSpeed/0.02
const JumpSpeed:=-200
var gravity:=ProjectSettings.get("physics/2d/default_gravity") as float

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_request_timer: Timer = $JumpRequestTimer

func _unhandled_input(event: InputEvent)->void:
    if event.is_action_pressed("jump"):
        jump_request_timer.start()
    if event.is_action_released("jump"):
        jump_request_timer.start()
    if velocity.y<JumpSpeed/2:
        velocity.y=JumpSpeed/2

func _physics_process(delta: float)->void:
    var direction:=Input.get_axis("move_left","move_right")
    var Acceleration:=Floor_Accleration if is_on_floor()else Air_Accleration
    velocity.x=move_toward(velocity.x,direction*RunSpeed,Acceleration*delta)
    velocity.y+=gravity*delta
    
    var canjump:=is_on_floor() or coyote_timer.time_left>0
    var pressedjump:=canjump and jump_request_timer.time_left>0
    if pressedjump:
        velocity.y = JumpSpeed
        coyote_timer.stop()
        jump_request_timer.stop()
    
    if is_on_floor():
        if is_zero_approx(direction) and is_zero_approx(velocity.x):
            animation_player.play("idle")
        else:
            animation_player.play("Running")
    else:
        animation_player.play("jump")
    
    if not is_zero_approx(direction):
        sprite_2d.flip_h=direction<0
     
    var was_on_floor:=is_on_floor()
    move_and_slide()
    
    if is_on_floor()!=was_on_floor:
        if was_on_floor and not canjump:
            coyote_timer.start()
        else:
            coyote_timer.stop()
# 法术能力
var max_spell_power = 100
var current_spell_power = 100
var activated_characters = [""]

# 法术方法
func _input(event):
    if Input.is_action_just_pressed("spell_appear"):
        cast_spell("appear")
    elif Input.is_action_just_pressed("spell_erase"):
        cast_spell("erase")
    elif Input.is_action_just_pressed("spell_modify"):
        cast_spell("modify")

func cast_spell(spell_type):
    if current_spell_power <= 0:
        return
        
    match spell_type:
        "appear":
            # 显现法术
            var ritual = get_closest_ritual()
            if ritual:
                ritual.appear_text()
                current_spell_power -= 20
        "erase":
            # 抹除法术
            var ritual = get_closest_ritual()
            if ritual:
                ritual.erase_text()
                current_spell_power -= 20
        "modify":
            # 修改法术
            var ritual = get_closest_ritual()
            if ritual:
                var choices = activated_characters.filter(func(c): c != "" )
                if choices.size() > 0:
                    ritual.modify_text(choices[0])
                    current_spell_power -= 30

func get_closest_ritual():
    var objects = get_tree().get_nodes_in_group("rituals")
    var closest = null
    var min_dist = INF
    
    for obj in objects:
        var dist = position.distance_to(obj.position)
        if dist < min_dist and dist < 200:  # 只考虑200单位内的机关
            min_dist = dist
            closest = obj
            
    return closest
