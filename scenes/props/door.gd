class_name Door
extends Node2D

signal opened

@onready var sprite := $DoorSprite

@export var duration_open : float
@export var enemies : Array[BasicEnemy]

enum State {CLOSED, OPENING, OPENED}

var door_height := 0
var state := State.CLOSED
var time_start_opening := Time.get_ticks_msec()

func _ready() -> void:
	door_height = sprite.texture.get_height()

func open() -> void:
	if state == State.CLOSED:
		state = State.OPENING
		time_start_opening = Time.get_ticks_msec()

func _process(_delta: float) -> void:
	if state == State.OPENING:
		if Time.get_ticks_msec() - time_start_opening > duration_open:
			state = State.OPENED
			sprite.position = Vector2.UP * door_height
			opened.emit()
		else:
			var progress := (Time.get_ticks_msec() - time_start_opening) / duration_open
			sprite.position = lerp(Vector2.ZERO, Vector2.UP * door_height, progress)
			
