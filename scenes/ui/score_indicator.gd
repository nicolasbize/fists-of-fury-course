class_name ScoreIndicator
extends Label

@export var duration_score_update : float

var displayed_score := 0
var prior_score := 0
var real_score := 0
var time_start_update := Time.get_ticks_msec()


func _ready() -> void:
	refresh()

func add_combo(points: int) -> void:
	real_score += int((points * (points + 1)) / 2.0)
	prior_score = displayed_score
	time_start_update = Time.get_ticks_msec()
	refresh()

func _process(_delta: float) -> void:
	if real_score != displayed_score:
		var progress := (Time.get_ticks_msec() - time_start_update) / duration_score_update
		if progress < 1:
			displayed_score = lerp(prior_score, real_score, progress)
		else:
			displayed_score = real_score
		refresh()

func refresh() -> void:
	text = str(displayed_score)
	
