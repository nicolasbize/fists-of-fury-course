class_name Character
extends CharacterBody2D

const GRAVITY := 600.0

@export var can_respawn : bool
@export var damage : int
@export var max_health : int

@export_group("Movement")
@export var duration_grounded: float
@export var flight_speed : float
@export var jump_intensity : float
@export var knockback_intensity : float
@export var knockdown_intensity : float
@export var speed : float

@export_group("Weapons")
@export var autodestroy_on_drop : bool
@export var can_respawn_knives : bool
@export var damage_gunshot : int
@export var damage_power : int
@export var duration_between_knife_respawn : int
@export var has_knife : bool
@export var has_gun : bool
@export var max_ammo_per_gun : int

@onready var animation_player := $AnimationPlayer
@onready var character_sprite := $CharacterSprite
@onready var collateral_damage_emitter : Area2D = $CollateralDamageEmitter
@onready var collectible_sensor : Area2D = $CollectibleSensor
@onready var collision_shape := $CollisionShape2D
@onready var damage_emitter := $DamageEmitter
@onready var damage_receiver : DamageReceiver = $DamageReceiver
@onready var gun_sprite : Sprite2D = $GunSprite
@onready var knife_sprite : Sprite2D = $KnifeSprite
@onready var projectile_aim : RayCast2D = $ProjectileAim
@onready var weapon_position : Node2D = $KnifeSprite/WeaponPosition

enum State {IDLE, WALK, ATTACK, TAKEOFF, JUMP, LAND, JUMPKICK, HURT, FALL, GROUNDED, DEATH, FLY, PREP_ATTACK, THROW, PICKUP, SHOOT, PREP_SHOOT}

var ammo_left := 0
var anim_attacks := []
var anim_map := {
	State.IDLE: "idle",
	State.WALK: "walk",
	State.ATTACK: "punch",
	State.TAKEOFF: "takeoff",
	State.JUMP: "jump",
	State.LAND: "land",
	State.JUMPKICK: "jumpkick",
	State.HURT: "hurt",
	State.FALL: "fall",
	State.GROUNDED: "grounded",
	State.DEATH: "grounded",
	State.FLY: "fly",
	State.PREP_ATTACK: "idle",
	State.THROW: "throw",
	State.PICKUP: "pickup",
	State.SHOOT: "shoot",
	State.PREP_SHOOT: "idle",
}
var attack_combo_index := 0
var current_health := 0
var heading := Vector2.RIGHT
var height := 0.0
var height_speed := 0.0
var is_last_hit_successful := false
var state := State.IDLE
var time_since_grounded := Time.get_ticks_msec()
var time_since_knife_dismiss := Time.get_ticks_msec()

func _ready() -> void:
	damage_emitter.area_entered.connect(on_emit_damage.bind())
	damage_receiver.damage_received.connect(on_receive_damage.bind())
	collateral_damage_emitter.area_entered.connect(on_emit_collateral_damage.bind())
	collateral_damage_emitter.body_entered.connect(on_wall_hit.bind())
	current_health = max_health

func _process(delta: float) -> void:
	handle_input()
	handle_movement()
	handle_animations()
	handle_air_time(delta)
	handle_prep_attack()
	handle_prep_shoot()
	handle_grounded()
	handle_knife_respawn()
	handle_death(delta)
	set_heading()
	flip_sprites()
	knife_sprite.visible = has_knife
	gun_sprite.visible = has_gun
	character_sprite.position = Vector2.UP * height
	knife_sprite.position = Vector2.UP * height
	gun_sprite.position = Vector2.UP * height
	collision_shape.disabled = is_collision_disabled()
	damage_emitter.monitoring = is_attacking()
	damage_receiver.monitorable = can_get_hurt()
	move_and_slide()

func handle_movement() -> void:
	if can_move():
		if velocity.length() == 0:
			state = State.IDLE
		else:
			state = State.WALK

func handle_input() -> void:
	pass

func handle_prep_attack() -> void:
	pass

func handle_prep_shoot() -> void:
	pass

func handle_grounded() -> void:
	if state == State.GROUNDED and (Time.get_ticks_msec() - time_since_grounded > duration_grounded):
		if current_health == 0:
			state = State.DEATH
		else:
			state = State.LAND

func handle_knife_respawn() -> void:
	if can_respawn_knives and not has_knife and (Time.get_ticks_msec() - time_since_knife_dismiss > duration_between_knife_respawn):
		has_knife = true

func handle_death(delta: float) -> void:
	if state == State.DEATH and not can_respawn:
		modulate.a -= delta / 2.0
		if modulate.a <= 0:
			queue_free()

func handle_animations() -> void:
	if state == State.ATTACK:
		animation_player.play(anim_attacks[attack_combo_index])
	elif animation_player.has_animation(anim_map[state]):
		animation_player.play(anim_map[state])

func handle_air_time(delta: float) -> void:
	if [State.JUMP, State.JUMPKICK, State.FALL].has(state):
		height += height_speed * delta
		if height < 0:
			height = 0
			if state == State.FALL:
				state = State.GROUNDED
				time_since_grounded = Time.get_ticks_msec()
			else:
				state = State.LAND
			velocity = Vector2.ZERO
		else:
			height_speed -= GRAVITY * delta

func set_heading() -> void:
	pass

func flip_sprites() -> void:
	if heading == Vector2.RIGHT:
		character_sprite.flip_h = false
		knife_sprite.scale.x = 1
		gun_sprite.scale.x = 1
		damage_emitter.scale.x = 1
		projectile_aim.scale.x = 1
	else:
		character_sprite.flip_h = true
		knife_sprite.scale.x = -1
		gun_sprite.scale.x = -1
		damage_emitter.scale.x = -1
		projectile_aim.scale.x = -1

func can_move() -> bool:
	return state == State.IDLE or state == State.WALK

func can_attack() -> bool:
	return state == State.IDLE or state == State.WALK

func can_jump() -> bool:
	return state == State.IDLE or state == State.WALK

func can_jumpkick() -> bool:
	return state == State.JUMP
	
func can_get_hurt() -> bool:
	return [State.IDLE, State.WALK, State.TAKEOFF, State.LAND, State.PREP_ATTACK].has(state)

func is_attacking() -> bool:
	return [State.ATTACK, State.JUMPKICK].has(state)

func is_carrying_weapon() -> bool:
	return has_knife or has_gun

func can_pickup_collectible() -> bool:
	if can_respawn_knives:
		return false
	var collectible_areas := collectible_sensor.get_overlapping_areas()
	if collectible_areas.size() == 0:
		return false
	var collectible : Collectible = collectible_areas[0]
	if collectible.type == Collectible.Type.KNIFE and not is_carrying_weapon():
		return true
	if collectible.type == Collectible.Type.GUN and not is_carrying_weapon():
		return true
	if collectible.type == Collectible.Type.FOOD:
		return true
	return false

func shoot_gun() -> void:
	state = State.SHOOT
	velocity = Vector2.ZERO
	var target_point := heading * (global_position.x + get_viewport_rect().size.x)
	var target := projectile_aim.get_collider()
	if target != null:
		target_point = projectile_aim.get_collision_point()
		target.on_receive_damage(damage_gunshot, heading, DamageReceiver.HitType.KNOCKDOWN)
	var weapon_root_position := Vector2(weapon_position.global_position.x, position.y)
	var weapon_height := -weapon_position.position.y
	var distance := target_point.x - weapon_position.global_position.x
	EntityManager.spawn_shot.emit(weapon_root_position, distance, weapon_height)

func pickup_collectible() -> void:
	if can_pickup_collectible():
		var collectible_areas := collectible_sensor.get_overlapping_areas()
		var collectible : Collectible = collectible_areas[0]
		if collectible.type == Collectible.Type.KNIFE and not has_knife:
			has_knife = true
		if collectible.type == Collectible.Type.GUN and not has_gun:
			has_gun = true
			ammo_left = max_ammo_per_gun
		if collectible.type == Collectible.Type.FOOD:
			current_health = max_health
		collectible.queue_free()
		
func is_collision_disabled() -> bool:
	return [State.GROUNDED, State.DEATH, State.FLY].has(state)

func on_action_complete() -> void:
	state = State.IDLE

func on_throw_complete() -> void:
	state = State.IDLE
	var collectible_type := Collectible.Type.KNIFE
	if has_gun:
		collectible_type = Collectible.Type.GUN
		has_gun = false
	else:
		has_knife = false
	
	var collectible_global_position := Vector2(weapon_position.global_position.x, global_position.y)
	var collectible_height := -weapon_position.position.y
	EntityManager.spawn_collectible.emit(collectible_type, Collectible.State.FLY, collectible_global_position, heading, collectible_height, false)

func on_takeoff_complete() -> void:
	state = State.JUMP
	height_speed = jump_intensity

func on_pickup_complete() -> void:
	state = State.IDLE
	pickup_collectible()

func on_land_complete() -> void:
	state = State.IDLE

func on_receive_damage(amount: int, direction: Vector2, hit_type: DamageReceiver.HitType) -> void:
	if can_get_hurt():
		attack_combo_index = 0
		can_respawn_knives = false
		if has_knife:
			has_knife = false
			EntityManager.spawn_collectible.emit(Collectible.Type.KNIFE, Collectible.State.FALL, global_position, Vector2.ZERO, 0.0, autodestroy_on_drop)
			time_since_knife_dismiss = Time.get_ticks_msec()
		if has_gun:
			has_gun = false
			EntityManager.spawn_collectible.emit(Collectible.Type.GUN, Collectible.State.FALL, global_position, Vector2.ZERO, 0.0, autodestroy_on_drop)
		current_health = clamp(current_health - amount, 0, max_health)
		if current_health == 0 or hit_type == DamageReceiver.HitType.KNOCKDOWN:
			state = State.FALL
			height_speed = knockdown_intensity
			velocity = direction * knockback_intensity
		elif hit_type == DamageReceiver.HitType.POWER:
			state = State.FLY
			velocity = direction * flight_speed
		else:
			state = State.HURT
			velocity = direction * knockback_intensity

func on_emit_damage(receiver: DamageReceiver) -> void:
	var hit_type := DamageReceiver.HitType.NORMAL
	var direction := Vector2.LEFT if receiver.global_position.x < global_position.x else Vector2.RIGHT
	var current_damage = damage
	if state == State.JUMPKICK:
		hit_type = DamageReceiver.HitType.KNOCKDOWN
	if attack_combo_index == anim_attacks.size() - 1:
		hit_type = DamageReceiver.HitType.POWER
		current_damage = damage_power
	receiver.damage_received.emit(current_damage, direction, hit_type)
	is_last_hit_successful = true

func on_emit_collateral_damage(receiver: DamageReceiver) -> void:
	if receiver != damage_receiver:
		var direction := Vector2.LEFT if receiver.global_position.x < global_position.x else Vector2.RIGHT
		receiver.damage_received.emit(0, direction, DamageReceiver.HitType.KNOCKDOWN)

func on_wall_hit(_wall: AnimatableBody2D) -> void:
	state = State.FALL
	height_speed = knockback_intensity
	velocity = -velocity / 2.0
	
