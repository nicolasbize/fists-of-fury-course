class_name FlickeringTextureRect
extends TextureRect

@export var duration_flicker : int
@export var total_flickers : int

var flickers_left := 0
var image : Texture2D = null
var is_flickering := false
var time_start_last_flicker := Time.get_ticks_msec()

func _ready() -> void:
	image = texture
	texture = null

func start_flickering() -> void:
	flickers_left = total_flickers
	is_flickering = true
	time_start_last_flicker = Time.get_ticks_msec()
	SoundPlayer.play(SoundManager.Sound.GOGOGO)

func _process(_delta: float) -> void:
	if is_flickering and (Time.get_ticks_msec() - time_start_last_flicker > duration_flicker):
		if texture == null:
			if flickers_left == 0:
				is_flickering = false
			else:
				flickers_left -= 1
				texture = image
		else:
			texture = null
		time_start_last_flicker = Time.get_ticks_msec()
