class_name Stunner extends Area2D

@export var roaming_mode : Roamer.RoamerMode

@export var stun_length : float = 2.0
@export var visual: AnimatedSprite2D

@export_group('vertical or horizontal or circular')
@export var roaming_radius : float = 64
@export var roaming_speed : float = 64

@export_group('internals')
@export var custom_waypoints : Array[Marker2D] = []
@export var stunned : bool = false
@export var initial_position : Vector2
@export var direction : float = 1
@export var stun_elapsed : float = 0.0
@export var grapple_target : GrappleTarget
@export var kill_on_exit: bool = false

func stun():
	set_deferred('monitorable', false)
	set_deferred('monitoring',  false)
	grapple_target.set_deferred('monitorable', false)
	grapple_target.set_deferred('monitoring',  false)
	grapple_target.set_deferred('collision_layer',  0)
	stun_elapsed = 0.0
	stunned = true
	visual.play("close")

func unstun():
	set_deferred('monitorable', true)
	set_deferred('monitoring',  true)
	grapple_target.set_deferred('monitorable', true)
	grapple_target.set_deferred('monitoring',  true)
	grapple_target.set_deferred('collision_layer',  16)
	stun_elapsed = 0.0
	stunned = false
	visual.play("fly")

func setup_for_custom():
	if not custom_waypoints or custom_waypoints.is_empty():
		for c:Node in get_children():
			if c is Marker2D: custom_waypoints.push_back(c)
	if not custom_waypoints or custom_waypoints.is_empty():
		push_error('must have custom_waypoints %s' % get_path())

func _ready() -> void:
	if roaming_mode == Roamer.RoamerMode.CUSTOM: setup_for_custom()
	if not grapple_target: grapple_target = %GrappleTarget
	initial_position = global_position
	visual.play("fly")

func physics_manual(_delta:float):
	set_physics_process(false)

func physics_custom(_delta:float):
	push_error('physics_custom is not implemented, pick horizontal/vertical/circular %s' % get_path())
	set_physics_process(false)

func physics_horizontal(delta:float):
	global_position.x += direction * delta * roaming_speed
	if initial_position.distance_to(global_position) >= roaming_radius:
		direction *= -1

func physics_vertical(delta:float):
	global_position.y += direction * delta * roaming_speed
	if initial_position.distance_to(global_position) >= roaming_radius:
		if kill_on_exit:
			queue_free()
		direction *= -1

func physics_circular(delta:float):
	var angle := initial_position.angle_to_point(global_position)
	if rad_to_deg(angle) <= 180:
		direction = 1
	else:
		direction = -1
	angle += delta * deg_to_rad(roaming_speed)
	global_position = initial_position + (roaming_radius * Vector2(cos(angle), sin(angle)))

func _physics_process(delta: float) -> void:
	if stunned:
		stun_elapsed += delta
		if stun_elapsed > stun_length: unstun()
		else: return
		
	match roaming_mode:
		Roamer.RoamerMode.MANUAL: physics_manual(delta)
		Roamer.RoamerMode.CUSTOM: physics_custom(delta)
		Roamer.RoamerMode.HORIZONTAL: physics_horizontal(delta)
		Roamer.RoamerMode.VERTICAL: physics_vertical(delta)
		Roamer.RoamerMode.CIRCULAR: physics_circular(delta)
	visual.scale.x = direction
