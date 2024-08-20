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

static var spawned_enemies : Array[Node] = []

func _unhandled_key_input(event: InputEvent) -> void:
	var ke := event as InputEventKey
	if not ke: return
	if not ke.is_pressed(): return
	if ke.keycode == KEY_F7: await on_weakpoint_hit()

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
			await on_boss_phase_changed()
		BossPhases.MID:
			boss_phase = BossPhases.ALMOST_DEAD
			await on_boss_phase_changed()
		BossPhases.ALMOST_DEAD:
			boss_phase = BossPhases.DEATH_ANIMATION
			await on_boss_phase_changed()

var animating : bool = false

var tween : Tween

func on_boss_phase_changed():
	if dead: return
	while animating:
		await get_tree().create_timer(0.1).timeout
	match boss_phase:
		BossPhases.MID:
			animating = true
			await hurt()
			if tween and tween.is_running(): tween.kill()
			tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(self, "position", Vector2(0, -848), 34.0)
			await tween.finished
			animating = false
		BossPhases.ALMOST_DEAD:
			await hurt()
			if tween and tween.is_running(): tween.kill()
			tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(self, "position", Vector2(0, -1288), 34.0)
			await tween.finished
			animating = false
		BossPhases.DEATH_ANIMATION:
			animating = true
			await hurt()
			await die()
			animating = false

func die():
	dead = true
	animating = true
	if tween and tween.is_running(): tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", Vector2(0, -128), 3.0)
	await tween.finished
	print_verbose('tween finished')
	animator.play("die")
	await animator.animation_finished
	print_verbose('die finished')
	animating = false
	queue_free()

func hurt() -> void:
	if dead:
		return
	if weakpoint.health > 0:
		animating = true
		speed *= speed_scale
		animator.play("hurt")
		await get_tree().create_timer(0.1).timeout
		await animator.animation_finished
		animating = false
		return

func _exit_tree() -> void:
	for enemy:Node in spawned_enemies:
		if enemy and not enemy.is_queued_for_deletion(): enemy.queue_free()
	spawned_enemies.clear()

func spawn_drone(x: float = position.x, y: float = position.y) -> void:
	var instance: Roamer = drone_scene.instantiate() as Roamer
	add_sibling.call_deferred(instance)
	instance.global_position = Vector2(x, y)
	instance.roaming_mode = Roamer.RoamerMode.VERTICAL
	instance.roaming_radius = drone_cover_distance
	instance.kill_on_exit = true
	instance.direction = 1
	spawned_enemies.push_back(instance)
	instance.tree_exiting.connect(spawned_enemies.erase.bind(instance), CONNECT_ONE_SHOT)

func spawn_stunner(x: float = position.x, y: float = position.y) -> void:
	var instance: Stunner = stunner_scene.instantiate() as Stunner
	add_sibling.call_deferred(instance)
	instance.global_position = Vector2(x, y)
	instance.roaming_mode = Roamer.RoamerMode.VERTICAL
	instance.roaming_radius = drone_cover_distance
	instance.kill_on_exit = true
	instance.direction = 1
	spawned_enemies.push_back(instance)
	instance.tree_exiting.connect(spawned_enemies.erase.bind(instance), CONNECT_ONE_SHOT)
