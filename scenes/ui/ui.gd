class_name UI
extends CanvasLayer

@onready var enemy_avatar : TextureRect = $UIContainer/EnemyAvatar
@onready var enemy_healthbar : Healthbar = $UIContainer/EnemyHealthbar
@onready var player_healthbar : Healthbar = $UIContainer/PlayerHealthbar

@export var duration_healthbar_visible : int

var time_start_healthbar_visible := Time.get_ticks_msec()

const avatar_map : Dictionary = {
	Character.Type.GOON: preload("res://assets/art/ui/avatars/avatar-goon.png"),
	Character.Type.PUNK: preload("res://assets/art/ui/avatars/avatar-punk.png"),
	Character.Type.THUG: preload("res://assets/art/ui/avatars/avatar-thug.png"),
	Character.Type.BOUNCER: preload("res://assets/art/ui/avatars/avatar-boss.png"),
}

func _init() -> void:
	DamageManager.health_change.connect(on_character_health_change.bind())

func _ready() -> void:
	enemy_avatar.visible = false
	enemy_healthbar.visible = false

func _process(_delta: float) -> void:
	if enemy_healthbar.visible and (Time.get_ticks_msec() - time_start_healthbar_visible > duration_healthbar_visible):
		enemy_avatar.visible = false
		enemy_healthbar.visible = false


func on_character_health_change(type: Character.Type, current_health: int, max_health: int) -> void:
	if type == Character.Type.PLAYER:
		player_healthbar.refresh(current_health, max_health)
	else:
		time_start_healthbar_visible = Time.get_ticks_msec()
		enemy_avatar.texture = avatar_map[type]
		enemy_healthbar.refresh(current_health, max_health)
		enemy_avatar.visible = true
		enemy_healthbar.visible = true
		
