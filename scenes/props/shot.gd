class_name Shot
extends Line2D

@export var duration_shot_across_screen : float

var duration_shot := 0.0
var height := 0.0
var shot_distance := 0.0
var time_start := Time.get_ticks_msec()

func initialize(distance: float, gun_height: float) -> void:
	height = gun_height
	shot_distance = distance
	add_point(Vector2(0, -height), 0)
	add_point(Vector2(distance, -height), 1)
	duration_shot = abs(shot_distance) * duration_shot_across_screen / get_viewport_rect().size.x

func _process(_delta: float) -> void:
	var elapsed := Time.get_ticks_msec() - time_start
	var progress := elapsed / duration_shot
	var new_x : float = lerp(0.0, shot_distance, progress)
	set_point_position(0, Vector2(new_x, -height))
	if progress >= 1:
		queue_free()
	
