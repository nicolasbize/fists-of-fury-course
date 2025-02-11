class_name SoundManager
extends Node

@onready var sounds : Array[AudioStreamPlayer] = [$SFXClick, $SFXFood, $SFXGogogo, $SFXGrunt, $SFXGunshot, $SFXHit1, $SFXHit2, $SFXKnife, $SFXSwoosh]

enum Sound {CLICK, FOOD, GOGOGO, GRUNT, GUNSHOT, HIT1, HIT2, KNIFE, SWOOSH}

func play(sfx: Sound, tweak_pitch: bool = false) -> void:
	var added_pitch := 0.0
	if tweak_pitch:
		added_pitch = randf_range(-0.3, 0.3)
	sounds[sfx as int].pitch_scale = 1 + added_pitch
	sounds[sfx as int].play()
