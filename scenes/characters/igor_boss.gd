class_name IgorBoss
extends Character

const GROUND_FRICTION := 50

@export var distance_from_player : int
@export var duration_between_attacks : int
@export var duration_vulnerable : int
@export var player : Player

var knockback_force := Vector2.ZERO
var time_last_attack := Time.get_ticks_msec()
var time_start_vulnerable := Time.get_ticks_msec()

func _process(delta: float) -> void:
	super._process(delta)
	knockback_force = knockback_force.move_toward(Vector2.ZERO, delta * GROUND_FRICTION)

func get_target_destination() -> Vector2:
	var target := Vector2.ZERO
	if position.x < player.position.x:
		target = player.position + Vector2.LEFT * distance_from_player
	else:
		target = player.position + Vector2.RIGHT * distance_from_player
	return target

func is_player_within_range() -> bool:
	var target := get_target_destination()
	return (target - position).length() < 1

func handle_grounded() -> void:
	if state == State.GROUNDED and current_health > 0:
		state = State.RECOVER
		time_start_vulnerable = Time.get_ticks_msec()
	elif state == State.RECOVER and Time.get_ticks_msec() - time_start_vulnerable > duration_vulnerable:
		state = State.IDLE
		time_last_attack = Time.get_ticks_msec()

func handle_input() -> void:
	if player != null and can_move():
		if can_attack() and projectile_aim.is_colliding():
			state = State.FLY
			velocity = heading * flight_speed
		else:
			if is_player_within_range():
				velocity = Vector2.ZERO
				state = State.IDLE
			else:
				var target_destination := get_target_destination()
				var direction := (target_destination - position).normalized()
				velocity = (direction + knockback_force) * speed
				state = State.WALK

func on_action_complete() -> void:
	if state == State.HURT:
		state = State.RECOVER
		return
	super.on_action_complete()

func set_heading() -> void:
	if player == null or not can_move():
		return
	heading = Vector2.LEFT if position.x > player.position.x else Vector2.RIGHT
	
func can_get_hurt() -> bool:
	return true

func can_attack() -> bool:
	if Time.get_ticks_msec() - time_last_attack < duration_between_attacks:
		return false
	return super.can_attack()

func is_vulnerable() -> bool:
	return state == State.RECOVER

func on_receive_damage(amount: int, direction: Vector2, hit_type: DamageReceiver.HitType) -> void:
	if not is_vulnerable():
		knockback_force = direction * knockback_intensity
		return
	current_health = clamp(current_health, 0, max_health)
	if current_health == 0:
		state = State.FALL
		height_speed = knockdown_intensity
		velocity = direction * knockdown_intensity
	else:
		velocity = Vector2.ZERO
		state = State.HURT

func on_emit_damage(receiver: DamageReceiver) -> void:
	receiver.damage_received.emit(damage, heading, DamageReceiver.HitType.KNOCKDOWN)
	time_last_attack = Time.get_ticks_msec()
	state = State.IDLE

func is_attacking() -> bool:
	return state == State.FLY
