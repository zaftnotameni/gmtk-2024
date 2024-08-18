class_name SinWaves extends Node

@export_group('configuration')
@export var amplitude_x : float = 0
@export var amplitude_y : float = 8
@export var speed_x : float = 0
@export var speed_y : float = 1

@export_group('internals')
@export var target : Node2D
@export var angle_x : float = 0
@export var angle_y : float = 0
@export var initial_x : float = 0
@export var initial_y : float = 0

func _ready() -> void:
	if not target and get_parent() is Node2D: target = get_parent()
	if not target and owner is Node2D: target = owner
	if not target: push_error('missing target (node2d) on %s' % get_path())
	if not target: return
	initial_x = target.global_position.x
	initial_y = target.global_position.y

func _physics_process(delta: float) -> void:
	if not target: return
	angle_x = wrap(angle_x + delta * speed_x, 0, 2 * PI)
	angle_y = wrap(angle_y + delta * speed_y, 0, 2 * PI)
	target.global_position.x = initial_x + sin(angle_x) * amplitude_x
	target.global_position.y = initial_y + sin(angle_y) * amplitude_y
