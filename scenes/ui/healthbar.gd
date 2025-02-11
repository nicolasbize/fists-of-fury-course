class_name Healthbar
extends Control

@onready var content_background : ColorRect = $ContentBackground
@onready var health_gauge : TextureRect = $HealthGauge
@onready var white_border : ColorRect = $WhiteBorder

@export var is_inverted : bool

func refresh(current_health: int, max_health: int) -> void:
	var rev = -1 if is_inverted else 1
	white_border.scale.x = (max_health + 2) * rev
	content_background.scale.x = max_health * rev
	health_gauge.scale.x = current_health * rev
