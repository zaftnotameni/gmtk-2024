extends Node2D

@export var weakpoint: WeakPoint
@export var timer: Timer
@export var animator: AnimationPlayer
@export var drone_scene: PackedScene
@export var stunner_scene: PackedScene

@export_group("Movement")
@export var direction: float = 1 ## Which direction the boss moves in (left / right none)
@export var cover_distance: float = 128 ## How far away from the origin the boss can get
@export var drone_cover_distance: float = 576 * 3 ## How far drones travel before being deleted
@export var speed: float = 20 ## How quickly the boss moves
@export var speed_scale: float = 1.5 ## How much to multiply the speed each time the boss is hurt

var dead := false
var spawn_count : int = 0 # How many enemies have spawned (should be modulo 4)

enum BossPhases { ALMOST_DEAD, MID, CHILL, DEATH_ANIMATION }

var boss_phase := BossPhases.CHILL

func _unhandled_key_input(event: InputEvent) -> void:
	var ke := event as InputEventKey
	if not ke: return
	if not ke.is_pressed(): return
	if ke.keycode == KEY_F7: on_weakpoint_hit()

func _ready() -> void:
	weakpoint.sig_weakpoint_hit.connect(on_weakpoint_hit)
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

	match boss_phase:
		BossPhases.CHILL:
			if spawn_count >= 2:
				spawn_drone(position.x - 24, position.y + 32)
				spawn_drone(position.x + 24, position.y + 32)
			else:
				spawn_drone(position.x - 24, position.y + 32)
				spawn_drone(position.x + 24, position.y + 32)
		BossPhases.MID:
			if spawn_count >= 2:
				spawn_stunner(position.x - 24, position.y + 32)
				spawn_stunner(position.x + 24, position.y + 32)
			else:
				spawn_stunner(position.x - 24, position.y + 32)
				spawn_stunner(position.x + 24, position.y + 32)
		BossPhases.ALMOST_DEAD:
			if spawn_count == 0:
				spawn_stunner(position.x, position.y + 32)
			if spawn_count == 1:
				spawn_stunner(position.x - 24, position.y + 32)
			if spawn_count == 2:
				spawn_stunner(position.x, position.y + 32)
			if spawn_count == 3:
				spawn_stunner(position.x + 24, position.y + 32)

func on_weakpoint_hit() -> void:
	for p:PlayerControllerSnappy in PlayerControllerSnappy.all():
		p.change_grapple_state_to(PlayerControllerSnappy.GrappleState.COOLDOWN)
		p.character.velocity.y = 64

	match boss_phase:
		BossPhases.CHILL:
			boss_phase = BossPhases.MID
			on_boss_phase_changed()
		BossPhases.MID:
			boss_phase = BossPhases.ALMOST_DEAD
			on_boss_phase_changed()
		BossPhases.ALMOST_DEAD:
			boss_phase = BossPhases.DEATH_ANIMATION
			on_boss_phase_changed()


func on_boss_phase_changed():
	if dead: return
	match boss_phase:
		BossPhases.MID:
			hurt()
			await create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).tween_property(
				self, "position", Vector2(0, -848), 34.0
			).finished
		BossPhases.ALMOST_DEAD:
			hurt()
			await create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).tween_property(
				self, "position", Vector2(0, -1288), 34.0
			).finished
		BossPhases.DEATH_ANIMATION:
			hurt()
			die()

func die():
	dead = true
	await create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).tween_property(
		self, "position", Vector2(0, -128), 6.0
	).finished
	animator.play("die")
	await animator.animation_finished
	queue_free()

func hurt() -> void:
	if dead:
		return
	if weakpoint.health > 0:
		speed *= speed_scale
		animator.play("hurt")
		return

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
	add_sibling.call_deferred(instance)
	instance.global_position = Vector2(x, y)
	instance.roaming_mode = Roamer.RoamerMode.VERTICAL
	instance.roaming_radius = drone_cover_distance
	instance.kill_on_exit = true
	instance.direction = 1
