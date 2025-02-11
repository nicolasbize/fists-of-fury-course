class_name Camera
extends Camera2D

@export var duration_shake : int
@export var shake_intensity : int

var is_shaking := false
var time_start_shaking := Time.get_ticks_msec()

func _init() -> void:
	DamageManager.heavy_blow_received.connect(on_heavy_blow_received.bind())

func on_heavy_blow_received() -> void:
	is_shaking = true
	time_start_shaking = Time.get_ticks_msec()

func _process(_delta: float) -> void:
	if is_shaking and (Time.get_ticks_msec() - time_start_shaking < duration_shake):
		offset = Vector2(randi_range(-shake_intensity, shake_intensity), randi_range(-shake_intensity, shake_intensity))
	else:
		offset = Vector2.ZERO
		is_shaking = false
