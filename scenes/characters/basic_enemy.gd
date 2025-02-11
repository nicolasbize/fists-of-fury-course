class_name BasicEnemy
extends Character

const EDGE_SCREEN_BUFFER := 10

@export var duration_between_melee_attacks : int
@export var duration_between_range_attacks : int
@export var duration_prep_melee_attack : int
@export var duration_prep_range_attack : int
@export var player : Player

var player_slot : EnemySlot = null
var time_since_last_melee_attack := Time.get_ticks_msec()
var time_since_prep_melee_attack := Time.get_ticks_msec()
var time_since_last_range_attack := Time.get_ticks_msec()
var time_since_prep_range_attack := Time.get_ticks_msec()

func _ready() -> void:
	super._ready()
	anim_attacks = ["punch", "punch_alt"]
	
func handle_input() -> void:
	if player != null and can_move():
		if can_respawn_knives or has_knife or has_gun:
			goto_range_position()
		else:
			goto_melee_position()

func goto_range_position() -> void:
	var camera := get_viewport().get_camera_2d()
	var screen_width := get_viewport_rect().size.x
	var screen_left_edge := camera.position.x - screen_width / 2
	var screen_right_edge := camera.position.x + screen_width / 2
	
	var left_destination := Vector2(screen_left_edge + EDGE_SCREEN_BUFFER, player.position.y)
	var right_destination := Vector2(screen_right_edge - EDGE_SCREEN_BUFFER, player.position.y)
	var closest_destination := Vector2.ZERO
	if (left_destination - position).length() < (right_destination - position).length():
		closest_destination = left_destination
	else:
		closest_destination = right_destination
	if (closest_destination - position).length() < 1:
		velocity = Vector2.ZERO
	else:
		velocity = (closest_destination - position).normalized() * speed
	
	if can_range_attack() and has_knife and projectile_aim.is_colliding():
		state = State.THROW
		time_since_knife_dismiss = Time.get_ticks_msec()
		time_since_last_range_attack = Time.get_ticks_msec()
	
	if can_range_attack() and has_gun and projectile_aim.is_colliding():
		state = State.PREP_SHOOT
		time_since_prep_range_attack = Time.get_ticks_msec()

func handle_prep_shoot() -> void:
	if state == State.PREP_SHOOT and (Time.get_ticks_msec() - time_since_prep_range_attack > duration_prep_range_attack):
		shoot_gun()
		time_since_last_range_attack = Time.get_ticks_msec()

func goto_melee_position() -> void:
	if can_pickup_collectible():
		state = State.PICKUP
		if player_slot != null:
			player.free_slot(self)
	elif player_slot == null:
		player_slot = player.reserve_slot(self)
	
	if player_slot != null:
		var direction := (player_slot.global_position - global_position).normalized()
		if is_player_within_range():
			velocity = Vector2.ZERO
			if can_attack():
				state = State.PREP_ATTACK
				time_since_prep_melee_attack = Time.get_ticks_msec()
		else:
			velocity = direction * speed
	

func handle_prep_attack() -> void:
	if state == State.PREP_ATTACK and (Time.get_ticks_msec() - time_since_prep_melee_attack > duration_prep_melee_attack):
		state = State.ATTACK
		time_since_last_melee_attack = Time.get_ticks_msec()
		anim_attacks.shuffle()

func is_player_within_range() -> bool:
	return (player_slot.global_position - global_position).length() < 1

func can_attack() -> bool:
	if Time.get_ticks_msec() - time_since_last_melee_attack < duration_between_melee_attacks:
		return false
	return super.can_attack()

func can_range_attack() -> bool:
	if Time.get_ticks_msec() - time_since_last_range_attack < duration_between_range_attacks:
		return false
	return super.can_attack()

func set_heading() -> void:
	if player == null or not can_move():
		return
	heading = Vector2.LEFT if position.x > player.position.x else Vector2.RIGHT

func on_receive_damage(amount: int, direction: Vector2, hit_type: DamageReceiver.HitType) -> void:
	super.on_receive_damage(amount, direction, hit_type)
	if current_health == 0:
		player.free_slot(self)
