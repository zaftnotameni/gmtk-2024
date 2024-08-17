class_name Checkpoint extends Area2D

const GROUP := 'checkpoints'

@export var active : bool = false
@export var spawn_on_ready : bool = false
@export var animator: AnimationPlayer

@export_group('internals')
@export var scene : PackedScene

func _unhandled_input(event: InputEvent) -> void:
	if not active: return
	if PlayerInput.is_respawn(event): await spawn()

func _enter_tree() -> void:
	add_to_group(GROUP)
	if not scene: scene = load('res://game/scenes/player/player.tscn')

func _ready() -> void:
	if spawn_on_ready: spawn.call_deferred()
	body_entered.connect(on_body_entered)
	if active: activate()

func on_body_entered(body:Node2D):
	if body is Player: activate()

func activate():
	for cp:Checkpoint in all():
		if cp != self: cp.deactivate()
	active = true

func spawn():
	for p:CharacterBody2D in Player.all():
		p.queue_free()
		await p.tree_exited
	var p := scene.instantiate() as Node2D
	p.global_position = global_position
	Layers.game.add_child(p)
	p.process_mode = Node.PROCESS_MODE_DISABLED
	p.hide()
	animator.play("flash")
	await animator.animation_finished
	p.process_mode = Node.PROCESS_MODE_INHERIT
	p.show()


func deactivate():
	active = false

static func tree() -> SceneTree: return Engine.get_main_loop()

static func all() -> Array: return tree().get_nodes_in_group(GROUP)

static func current() -> Checkpoint:
	for cp:Checkpoint in all():
		if cp.active: return cp
	return null
