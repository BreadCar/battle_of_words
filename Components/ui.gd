extends HBoxContainer
@onready var player: Player = $"../.."

var ability
@onready var up: Label = $GridContainer/Ability1/up
@onready var down: Label = $GridContainer/Ability2/down
@onready var left: Label = $GridContainer/Ability3/left
@onready var right: Label = $GridContainer/Ability4/right
@onready var tru: Label = $GridContainer/Ability5/tru
@onready var fals: Label = $GridContainer/Ability6/fals

func _ready() -> void:
	player.ability_gained.connect(refresh_ability_panel)

func refresh_ability_panel() -> void:
	ability = player.player_skills
	up.visible = ability["up"]
	down.visible = ability["down"]
	left.visible = ability["left"] 
	right.visible = ability["right"]
	tru.visible = ability["true"]
	fals.visible = ability["false"]
