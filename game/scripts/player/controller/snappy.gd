class_name PlayerControllerSnappy extends Node

enum PlayerState { INITIAL, GROUNDED, AIRBORNE, HOOK_IMPULSE, HOOKING }
enum GrappleState { READY, COOLDOWN, FIRING, HIT }

const GROUP := 'snappy'

@export_category('configuration')
@export var initial_speed_ground : float = 200
@export var initial_speed_air : float = 200
@export var gravity_up : float = 800
@export var gravity_down : float = 800
@export var max_speed_down : float = 600
@export var rope_max_length : float = 64
@export var rope_impulse : float = 200
@export var grapple_impulse : float = 300
@export var grapple_impulse_platform : float = 220
@export var hook_impulse_time : float = 0.01
@export var hook_impulse_elapsed : float = 0.0

@export_category('internals')
@export var player_state : PlayerState
@export var grapple_state : GrappleState
@export var grapple_target : Node2D
@export var grapple_cooldown_elapsed : float = 0
@export var grapple_cooldown_time : float = 0.5

@export_category('nodes')
@export var character : CharacterBody2D
@export var rope : Line2D
@export var cast : RayCast2D
@export var sprite : AnimatedSprite2D
@export var hook : Sprite2D
@export var stun : Area2D

func _enter_tree() -> void:
	add_to_group(GROUP)
	if not character: character = owner

func _ready() -> void:
	if not rope: rope = %Rope
	if not cast: cast = %Cast
	if not sprite: sprite = %Sprite
	if not hook: hook = %Hook
	if not stun: stun = %HookStunner

func default_physics(delta:float) -> void:
	var input := PlayerInput.xy_normalized()
	if character.is_on_floor():
		character.velocity.x = input.x * initial_speed_ground
	else:
		character.velocity.x = input.x * initial_speed_air

	if not character.is_on_floor():
		if character.velocity.y < 0: character.velocity.y += gravity_up * delta
		if character.velocity.y >= 0: character.velocity.y += gravity_down * delta
		if character.velocity.y >= max_speed_down: character.velocity.y = max_speed_down

	character.move_and_slide()

	if character.is_on_floor():
		player_state = PlayerState.GROUNDED
		if abs(input.x) > 0.1:
			sprite.play('run')
		else:
			sprite.play('idle')

	if not character.is_on_floor():
		player_state = PlayerState.AIRBORNE
		sprite.play('air')

func hook_impulse_physics(delta:float) -> void:
	var input := PlayerInput.xy_normalized()
	if character.is_on_floor():
		character.velocity.x = input.x * initial_speed_ground
	else:
		character.velocity.x = input.x * initial_speed_air

	hook_impulse_elapsed += delta

	character.move_and_slide()

	if hook_impulse_elapsed > hook_impulse_time:
		player_state = PlayerState.AIRBORNE

func _unhandled_input(event: InputEvent) -> void:
	if PlayerInput.is_grapple(event): initiate_grapple()

func initiate_grapple() -> void:
	if grapple_state != GrappleState.READY: return
	grapple_state = GrappleState.FIRING
	player_state = PlayerState.HOOKING
	rope.points[-1] = Vector2.ZERO
	hook.global_position = rope.to_global(rope.points[-1])
	hook.show()

func reset_grapple():
	clear_grapple_target()
	grapple_state = GrappleState.READY
	if character.is_on_floor():
		player_state = PlayerState.GROUNDED
	if not character.is_on_floor():
		player_state = PlayerState.AIRBORNE

func clear_grapple_target():
	hook.hide()
	rope.points[-1] = Vector2.ZERO
	hook.global_position = rope.to_global(rope.points[-1])
	if grapple_target and grapple_target.get_parent() and grapple_target.get_parent().has_method('ungrapple'):
		grapple_target.get_parent().ungrapple()
	grapple_target = null

func grapple_ready_physics(_delta:float) -> void:
	grapple_cooldown_elapsed = 0.0
	clear_grapple_target()

func grapple_cooldown_physics(delta:float) -> void:
	clear_grapple_target()
	grapple_cooldown_elapsed += delta
	if character.velocity.y < 0: character.velocity.y = 0
	if grapple_cooldown_elapsed > grapple_cooldown_time:
		grapple_cooldown_elapsed = 0
		grapple_state = GrappleState.READY

func grapple_firing_physics(delta:float) -> void:
	sprite.play('hook')
	grapple_cooldown_elapsed = 0.0
	rope.points[-1].y -= rope_impulse * delta
	hook.global_position = rope.to_global(rope.points[-1])
	hook.show()
	if abs(rope.points[-1].y) > rope_max_length:
		rope.points[-1].y = -rope_max_length
		hook.global_position = rope.to_global(rope.points[-1])
		grapple_state = GrappleState.READY
		hook.hide()
		if character.is_on_floor():
			player_state = PlayerState.GROUNDED
		if not character.is_on_floor():
			player_state = PlayerState.AIRBORNE
			grapple_state = GrappleState.COOLDOWN
	if cast.is_colliding():
		if cast.get_collider() is TileMapLayer:
			var layer := cast.get_collider() as TileMapLayer
			if not layer: return
			var coords := layer.get_coords_for_body_rid(cast.get_collider_rid())
			var data := layer.get_cell_tile_data(coords)
			if not data: return
			if data.get_custom_data('tile_type') == 'one_way':
				grapple_state = GrappleState.HIT
				grapple_target = OneWayPlatform.new()
				grapple_target.global_position = cast.get_collision_point() + Vector2(0, 0)
		elif cast.get_collider() is GrappleTarget:
			grapple_state = GrappleState.HIT
			grapple_target = cast.get_collider()
			if grapple_target and grapple_target.get_parent().has_method('grapple'):
				grapple_target.get_parent().grapple()
		elif cast.get_collider() is OneWayPlatform:
			grapple_state = GrappleState.HIT
			grapple_target = cast.get_collider()
		else:
			if not character.is_on_floor():
				grapple_state = GrappleState.COOLDOWN

func grapple_hit_physics(_delta:float) -> void:
	grapple_cooldown_elapsed = 0.0
	sprite.play('hook')
	character.velocity.x = 0
	if grapple_target is OneWayPlatform:
		character.velocity.y = -grapple_impulse_platform
	else:
		character.velocity.y = -grapple_impulse
	if grapple_target:
		rope.points[-1].y = rope.to_local(grapple_target.global_position).y
		hook.global_position = rope.to_global(rope.points[-1])
		if character.global_position.y < grapple_target.global_position.y:
			grapple_state = GrappleState.READY
			player_state = PlayerState.HOOK_IMPULSE
			hook_impulse_elapsed = 0.0
			clear_grapple_target()
	else:
		clear_grapple_target()

	character.move_and_slide()

func movement_physics(delta:float) -> void:
	match player_state:
		PlayerState.INITIAL: default_physics(delta)
		PlayerState.GROUNDED: default_physics(delta)
		PlayerState.AIRBORNE: default_physics(delta)
		PlayerState.HOOKING: pass
		PlayerState.HOOK_IMPULSE: hook_impulse_physics(delta)

func _physics_process(delta: float) -> void:
	if State.game_state != GameManagerState.GameState.GAME: return
	var was_on_floor = character.is_on_floor()
	var input := PlayerInput.xy_normalized()
	if input.x > 0.1:
		sprite.flip_h = false
	if input.x < -0.1:
		sprite.flip_h = true
	match grapple_state:
		GrappleState.COOLDOWN:
			grapple_cooldown_physics(delta)
			movement_physics(delta)
		GrappleState.READY:
			grapple_ready_physics(delta)
			movement_physics(delta)
		GrappleState.FIRING:
			grapple_firing_physics(delta)
		GrappleState.HIT:
			grapple_hit_physics(delta)

	if character.is_on_floor() and was_on_floor and abs(character.velocity.x) > 0.2:
		AudioManager.play_sfx(AudioManager.sfx_metal_land, true)
	if character.is_on_floor() and not was_on_floor:
		AudioManager.play_sfx(AudioManager.sfx_metal_step, true)
	if character.is_on_wall():
		AudioManager.sfx_metal_step.stop()

static func tree() -> SceneTree: return Engine.get_main_loop()
static func all() -> Array: return tree().get_nodes_in_group(GROUP)
static func first() -> Player: return tree().get_first_node_in_group(GROUP)
