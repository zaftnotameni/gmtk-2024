extends Node2D


@export var weakpoint: WeakPoint
@export var animator: AnimationPlayer
@export var drone_scene: PackedScene

@export_group("Movement")
@export var direction: int = 1 ## Which direction the boss moves in (left / right none)
@export var cover_distance: int = 128 ## How far away from the origin the boss can get
@export var speed: int = 16 ## How quickly the boss moves
@export var speed_scale: int = 2 ## How much to multiply the speed each time the boss is hurt

var dead = false


func _ready() -> void:
	weakpoint.sig_weakpoint_hit.connect(hurt)


func _physics_process(delta: float) -> void:
	if dead:
		return
	position.x += speed * delta * direction
	if abs(position.x) >= cover_distance:
		position.x = direction * cover_distance
		direction *= -1


func hurt() -> void:
	if weakpoint.health > 0:
		speed *= speed_scale
		animator.play("hurt")
		return
	animator.play("die")
	dead = true
	await animator.animation_finished
	queue_free()


func spawn_drone(x: int, y: int) -> void:
	var instance: Node2D = drone_scene.instantiate() as Node2D
	add_sibling(instance)
	instance.global_position = Vector2(x, y)
