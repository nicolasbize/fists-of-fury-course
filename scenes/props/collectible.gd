class_name Collectible
extends Area2D

const GRAVITY := 600.0

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var collectible_sprite : Sprite2D = $CollectibleSprite

@export var knockdown_intensity : float
@export var speed : float
@export var type : Type

enum State {FALL, GROUNDED, FLY}
enum Type {KNIFE, GUN, FOOD}

var anim_map := {
	State.FALL: "fall",
	State.GROUNDED: "grounded",
	State.FLY: "fly",
}
var height := 0.0
var height_speed := 0.0
var state = State.FALL

func _ready() -> void:
	height_speed = knockdown_intensity

func _process(delta: float) -> void:
	handle_fall(delta)
	handle_animations()
	collectible_sprite.position = Vector2.UP * height

func handle_animations() -> void:
	animation_player.play(anim_map[state])

func handle_fall(delta) -> void:
	if state == State.FALL:
		height += height_speed * delta
		if height < 0:
			height = 0
			state = State.GROUNDED
		else:
			height_speed -= GRAVITY * delta
		
