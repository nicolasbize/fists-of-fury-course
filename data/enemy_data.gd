class_name EnemyData
extends Resource

@export var type : Character.Type
@export var global_position : Vector2

func _init(character_type : Character.Type = Character.Type.PUNK, position : Vector2 = Vector2.ZERO) -> void:
	type = character_type
	global_position = position
