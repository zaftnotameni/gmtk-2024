extends Node2D


@export var weakpoint: WeakPoint
@export var timer: Timer
@export var animator: AnimationPlayer
@export var drone_scene: PackedScene
@export var stunner_scene: PackedScene

@export_group("Movement")
@export var direction: int = 1 ## Which direction the boss moves in (left / right none)
@export var cover_distance: int = 128 ## How far away from the origin the boss can get
@export var drone_cover_distance: int = 576 * 3 ## How far drones travel before being deleted
@export var speed: int = 20 ## How quickly the boss moves
@export var speed_scale: int = 1.5 ## How much to multiply the speed each time the boss is hurt

var dead = false
var spawn_count = 0 # How many enemies have spawned (should be modulo 4)


func _ready() -> void:
	weakpoint.sig_weakpoint_hit.connect(hurt)
	timer.timeout.connect(timeout)
	spawn_drone()


func _physics_process(delta: float) -> void:
	if dead:
		return
	position.x += speed * delta * direction
	if abs(position.x) >= cover_distance:
		position.x = direction * cover_distance
		direction *= -1


func timeout() -> void:
	spawn_count = (spawn_count + 1) % 4
	if weakpoint.health > 1:
		if spawn_count >= 2:
			spawn_drone(position.x - 24, position.y + 32)
		else:
			spawn_drone(position.x + 24, position.y + 32)
	else:
		spawn_drone(position.x, position.y + 32)


func hurt() -> void:
	if dead:
		return
	if weakpoint.health > 0:
		speed *= speed_scale
		animator.play("hurt")
		return
	dead = true
	await create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).tween_property(
		self, "position", Vector2(0, -128), 3.0
	).finished
	animator.play("die")
	await animator.animation_finished
	queue_free()


func spawn_drone(x: float = position.x, y: float = position.y) -> void:
	var instance: Roamer = drone_scene.instantiate() as Roamer
	add_sibling.call_deferred(instance)
	instance.global_position = Vector2(x, y)
	instance.roaming_mode = Roamer.RoamerMode.VERTICAL
	instance.roaming_radius = drone_cover_distance
	instance.kill_on_exit = true
	instance.direction = 1


func spawn_stunner(x: float = position.x, y: float = position.y) -> void:
	var instance: Stunner = stunner_scene.instantiate() as Stunner
	add_sibling(instance)
	instance.global_position = Vector2(x, y)
	instance.roaming_mode = Roamer.RoamerMode.VERTICAL
	instance.roaming_radius = drone_cover_distance
	instance.kill_on_exit = true
	instance.direction = 1
