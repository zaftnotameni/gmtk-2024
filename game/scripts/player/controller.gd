class_name PlayerController extends Node

enum PlayerState { INITIAL, GROUNDED, AIRBORNE }
enum GrappleState { READY, FIRING, HIT }

@export_category('configuration')
@export var initial_speed_ground : float = 100
@export var initial_speed_air : float = 100
@export var gravity_up : float = 100
@export var gravity_down : float = 150
@export var rope_max_length : float = 100
@export var rope_accel : float = 200
@export var grapple_accel : float = 400

@export_category('internals')
@export var player_state : PlayerState
@export var grapple_state : GrappleState
@export var grapple_target : GrappleTarget

@export_category('nodes')
@export var character : CharacterBody2D
@export var rope : Line2D
@export var hook : Hook

func _enter_tree() -> void:
	if not character: character = owner

func _ready() -> void:
	if not rope: rope = %Rope
	if not hook: hook = %Hook
	hook.area_entered.connect(on_area_entered)

func default_physics(delta:float) -> void:
	var input := PlayerInput.xy_normalized()
	if character.is_on_floor():
		character.velocity.x = input.x * initial_speed_ground
	else:
		character.velocity.x = input.x * initial_speed_air

	if not character.is_on_floor():
		if character.velocity.y < 0: character.velocity.y += gravity_up * delta
		if character.velocity.y >= 0: character.velocity.y += gravity_down * delta

	character.move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if PlayerInput.is_grapple(event): initiate_grapple()

func initiate_grapple() -> void:
	grapple_state = GrappleState.FIRING

func grapple_ready_physics(_delta:float) -> void:
	rope.points[-1] = Vector2.ZERO
	hook.position = rope.points[-1]

func grapple_firing_physics(delta:float) -> void:
	rope.points[-1].y -= delta * rope_accel
	if abs(rope.points[-1].y) > rope_max_length:
		rope.points[-1].y = -rope_max_length
		grapple_state = GrappleState.READY
	hook.position.y = rope.points[-1].y

func grapple_hit_physics(delta:float) -> void:
	character.velocity.y -= delta * grapple_accel
	if grapple_target:
		rope.points[-1] = rope.to_local(grapple_target.global_position)
		if character.global_position.y < grapple_target.global_position.y:
			grapple_state = GrappleState.READY
			grapple_target = null
	else:
		grapple_state = GrappleState.READY
		grapple_target = null

	character.move_and_slide()

func movement_physics(delta:float) -> void:
	match player_state:
		PlayerState.INITIAL: default_physics(delta)
		PlayerState.GROUNDED: default_physics(delta)
		PlayerState.AIRBORNE: default_physics(delta)

func _physics_process(delta: float) -> void:
	match grapple_state:
		GrappleState.READY:
			grapple_ready_physics(delta)
			movement_physics(delta)
		GrappleState.FIRING:
			grapple_firing_physics(delta)
			movement_physics(delta)
		GrappleState.HIT:
			grapple_hit_physics(delta)

	if character.is_on_floor():
		player_state = PlayerState.GROUNDED
	if not character.is_on_floor():
		player_state = PlayerState.AIRBORNE

func on_grapple_target_hit(target:GrappleTarget) -> void:
	grapple_state = GrappleState.HIT
	grapple_target = target

func on_area_entered(other:Area2D) -> void:
	if grapple_state != GrappleState.FIRING: return
	if other is not GrappleTarget: return
	on_grapple_target_hit(other)
