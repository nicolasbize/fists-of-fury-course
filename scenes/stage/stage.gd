class_name Stage
extends Node2D

@onready var checkpoints : Node2D = $Checkpoints
@onready var containers : Node2D = $Containers
@onready var doors : Node2D = $Doors

func _ready() -> void:
	for container : Node2D in containers.get_children():
		EntityManager.orphan_actor.emit(container)
	
	for i in range(doors.get_child_count()):
		var door : Door = doors.get_child(i)
		for enemy in door.enemies:
			enemy.assigned_door_index = i
	
	for door : Node2D in doors.get_children():
		EntityManager.orphan_actor.emit(door)
	
	for checkpoint : Checkpoint in checkpoints.get_children():
		checkpoint.create_enemy_data()
