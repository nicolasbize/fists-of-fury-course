extends Node2D

const SHOT_PREFAB := preload("res://scenes/props/shot.tscn")

const PREFAB_MAP := {
	Collectible.Type.KNIFE: preload("res://scenes/props/knife.tscn"),
	Collectible.Type.GUN: preload("res://scenes/props/gun.tscn"),
	Collectible.Type.FOOD: preload("res://scenes/props/food.tscn"),
}
const ENEMY_MAP := {
	Character.Type.PUNK: preload("res://scenes/characters/basic_enemy.tscn"),
	Character.Type.GOON: preload("res://scenes/characters/goon_enemy.tscn"),
	Character.Type.THUG: preload("res://scenes/characters/thug_enemy.tscn"),
	Character.Type.BOUNCER: preload("res://scenes/characters/igor_boss.tscn"),
}

@export var player : Player

func _ready() -> void:
	EntityManager.spawn_collectible.connect(on_spawn_collectible.bind())
	EntityManager.spawn_shot.connect(on_spawn_shot.bind())
	EntityManager.spawn_enemy.connect(on_spawn_enemy.bind())
	
func on_spawn_collectible(type: Collectible.Type, initial_state: Collectible.State, collectible_global_position: Vector2, collectible_direction: Vector2, initial_height: float, autodestroy: bool) -> void:
	var collectible : Collectible = PREFAB_MAP[type].instantiate()
	collectible.state = initial_state
	collectible.height = initial_height
	collectible.global_position = collectible_global_position
	collectible.direction = collectible_direction
	collectible.autodestroy = autodestroy
	call_deferred("add_child", collectible)

func on_spawn_shot(gun_root_position: Vector2, distance_traveled: float, height: float):
	var shot : Shot = SHOT_PREFAB.instantiate()
	add_child(shot)
	shot.position = gun_root_position
	shot.initialize(distance_traveled, height)

func on_spawn_enemy(enemy_data: EnemyData) -> void:
	var enemy : Character = ENEMY_MAP[enemy_data.type].instantiate()
	enemy.global_position = enemy_data.global_position
	enemy.player = player
	add_child(enemy)
