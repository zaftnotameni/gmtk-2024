class_name PlayerControllerSnappy extends Node

enum PlayerState { INITIAL, GROUNDED, AIRBORNE, HOOK_IMPULSE, HOOKING }
enum GrappleState { READY, COOLDOWN, FIRING, HIT }

const GROUP := 'snappy'

static var combo_label_scene := load('res://game/scenes/combo/combo_label.tscn')

@export_category('configuration')
@export var initial_speed_ground : float = 160
@export var initial_speed_air : float = 160
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
@export_flags_2d_physics var initial_mask : int
@export_flags_2d_physics var initial_layer : int

@export_category('nodes')
@export var character : CharacterBody2D
@export var rope : Line2D
@export var cast : RayCast2D
@export var sprite : AnimatedSprite2D
@export var lightsprite : AnimatedSprite2D
@export var hook : Sprite2D
@export var stun : Area2D

func on_grapple_just_hit():
	PlayerControllerSnappy.chained_hooks_add()
	if chained_hooks_count >= 5:
		var combo_label := combo_label_scene.instantiate() as Label
		if not combo_label: return
		if not grapple_target: return
		if not cast.is_colliding(): return
		combo_label.text = ' %sx' % chained_hooks_count
		combo_label.global_position = cast.get_collision_point() + Vector2(-48, -48)
		Layers.game.add_child(combo_label)

func change_grapple_state_to(new_grapple_state:GrappleState=grapple_state):
	if grapple_state == new_grapple_state: return
	if new_grapple_state == GrappleState.HIT:
		on_grapple_just_hit()
	grapple_state = new_grapple_state

func _enter_tree() -> void:
	add_to_group(GROUP)
	if not character: character = owner

func _ready() -> void:
	if not rope: rope = %Rope
	if not cast: cast = %Cast
	if not sprite: sprite = %Sprite
	if not lightsprite: lightsprite = %Light
	if not hook: hook = %Hook
	if not stun: stun = %HookStunner
	initial_mask = character.collision_mask
	initial_layer = character.collision_layer

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
			lightsprite.play('run')
		else:
			sprite.play('idle')
			lightsprite.play('idle')

	if not character.is_on_floor():
		player_state = PlayerState.AIRBORNE
		sprite.play('air')
		lightsprite.play('air')

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
	change_grapple_state_to(GrappleState.FIRING)
	player_state = PlayerState.HOOKING
	rope.points[-1] = Vector2.ZERO
	hook.global_position = rope.to_global(rope.points[-1])
	hook.show()
	AudioManager.play_sfx(AudioManager.sfx_hook_shot, true)

func reset_grapple():
	clear_grapple_target()
	change_grapple_state_to(GrappleState.READY)
	if character.is_on_floor():
		player_state = PlayerState.GROUNDED
	if not character.is_on_floor():
		player_state = PlayerState.AIRBORNE

func clear_grapple_target():
	AudioManager.sfx_hook_rope.stop()
	hook.hide()
	rope.points[-1] = Vector2.ZERO
	hook.global_position = rope.to_global(rope.points[-1])
	if grapple_target and grapple_target.get_parent() and grapple_target.get_parent().has_method('ungrapple'):
		grapple_target.get_parent().ungrapple()
	grapple_target = null

func grapple_ready_physics(_delta:float) -> void:
	character.collision_mask = initial_mask
	character.collision_layer = initial_layer
	stun.monitoring = false
	stun.monitorable = false

	grapple_cooldown_elapsed = 0.0
	clear_grapple_target()

func grapple_cooldown_physics(delta:float) -> void:
	character.collision_mask = initial_mask
	character.collision_layer = initial_layer
	stun.monitoring = false
	stun.monitorable = false

	clear_grapple_target()
	grapple_cooldown_elapsed += delta
	if character.velocity.y < 0: character.velocity.y = 0
	if grapple_cooldown_elapsed > grapple_cooldown_time:
		grapple_cooldown_elapsed = 0
		change_grapple_state_to(GrappleState.READY)

func grapple_firing_physics(delta:float) -> void:
	character.collision_mask = initial_mask
	character.collision_layer = initial_layer
	stun.monitoring = true
	stun.monitorable = true

	sprite.play('hook')
	lightsprite.play('hook')
	grapple_cooldown_elapsed = 0.0
	rope.points[-1].y -= rope_impulse * delta
	hook.global_position = rope.to_global(rope.points[-1])
	hook.show()
	if abs(rope.points[-1].y) > rope_max_length:
		rope.points[-1].y = -rope_max_length
		hook.global_position = rope.to_global(rope.points[-1])
		change_grapple_state_to(GrappleState.READY)
		hook.hide()
		if character.is_on_floor():
			player_state = PlayerState.GROUNDED
		if not character.is_on_floor():
			player_state = PlayerState.AIRBORNE
			change_grapple_state_to(GrappleState.COOLDOWN)
	if cast.is_colliding():
		if cast.get_collider() is TileMapLayer:
			var layer := cast.get_collider() as TileMapLayer
			if not layer: return
			var coords := layer.get_coords_for_body_rid(cast.get_collider_rid())
			var data := layer.get_cell_tile_data(coords)
			if not data: return
			if data.get_custom_data('tile_type') == 'one_way':
				AudioManager.play_sfx(AudioManager.sfx_hook_grab, true)
				grapple_target = OneWayPlatform.new()
				change_grapple_state_to(GrappleState.HIT)
				grapple_target.global_position = cast.get_collision_point() + Vector2(0, 0)
		elif cast.get_collider() is GrappleTarget:
			print_verbose('hit grapple target %s' % cast.get_collider().get_path())
			AudioManager.play_sfx(AudioManager.sfx_hook_grab, true)
			grapple_target = cast.get_collider()
			change_grapple_state_to(GrappleState.HIT)
			if grapple_target and grapple_target.get_parent().has_method('grapple'):
				grapple_target.get_parent().grapple()
		elif cast.get_collider() is OneWayPlatform:
			AudioManager.play_sfx(AudioManager.sfx_hook_grab, true)
			grapple_target = cast.get_collider()
			change_grapple_state_to(GrappleState.HIT)
		else:
			if not character.is_on_floor():
				change_grapple_state_to(GrappleState.COOLDOWN)

func grapple_hit_physics(_delta:float) -> void:
	AudioManager.play_sfx(AudioManager.sfx_hook_rope, true)
	character.collision_mask = 0
	character.collision_layer = 0
	stun.monitoring = true
	stun.monitorable = true

	grapple_cooldown_elapsed = 0.0
	sprite.play('hook')
	lightsprite.play('hook')
	character.velocity.x = 0
	if grapple_target is OneWayPlatform:
		character.velocity.y = -grapple_impulse_platform
	else:
		character.velocity.y = -grapple_impulse
	if grapple_target:
		rope.points[-1].y = rope.to_local(grapple_target.global_position).y
		hook.global_position = rope.to_global(rope.points[-1])
		if character.global_position.y < grapple_target.global_position.y:
			change_grapple_state_to(GrappleState.READY)
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
		lightsprite.flip_h = false
	if input.x < -0.1:
		sprite.flip_h = true
		lightsprite.flip_h = true
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

	if character.is_on_floor() and grapple_state != GrappleState.HIT:
		PlayerControllerSnappy.chained_hooks_reset()

	if character.is_on_floor() and was_on_floor and abs(character.velocity.x) > 0.2:
		AudioManager.play_sfx(AudioManager.sfx_metal_step, true)
	if character.is_on_floor() and not was_on_floor:
		AudioManager.play_sfx(AudioManager.sfx_metal_land, true)
	if character.is_on_wall():
		AudioManager.sfx_metal_step.stop()

static func tree() -> SceneTree: return Engine.get_main_loop()
static func all() -> Array: return tree().get_nodes_in_group(GROUP)
static func first() -> Player: return tree().get_first_node_in_group(GROUP)
static func reset_grapple_owned_by(part:Node):
	for snappy:PlayerControllerSnappy in PlayerControllerSnappy.all():
		if snappy.owner == part.owner: snappy.reset_grapple()

static var chained_hooks_count : float = 0
static var chained_hooks_percentage : float = 0
static var chained_hooks_max : float = 20

static func get_chained_hooks_percentagae() -> float:
	return chained_hooks_percentage

static func get_chained_hooks_count() -> float:
	return chained_hooks_count

static func chained_hooks_add(how_many:float=1):
	chained_hooks_count += how_many
	chained_hooks_percentage = (chained_hooks_count / chained_hooks_max) if chained_hooks_max > 0 else 0.0
	if chained_hooks_percentage > 1: chained_hooks_percentage = 1
	print_verbose('chained hooks: %s (%.2f)' % [chained_hooks_count, chained_hooks_percentage])

static func chained_hooks_reset():
	if chained_hooks_count > 0: print_verbose('chained hooks reset!')
	chained_hooks_percentage *= 0.5
	chained_hooks_count = 0
