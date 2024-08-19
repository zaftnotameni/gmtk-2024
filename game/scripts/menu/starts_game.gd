class_name StartsGame extends Node

const FIRST_LEVEL := preload('res://game/scenes/level/level001.tscn')

@export_group('optional')
@export var menu : Control
@export var scene : PackedScene
@export var button : BaseButton

func on_pressed():
	var instance : Node2D = scene.instantiate()
	GameManagerState.reset_time()
	State.victory_time = 0
	State.transition_start()
	Layers.game.add_child.call_deferred(instance)
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_pause_mode(Tween.TweenPauseMode.TWEEN_PAUSE_PROCESS)
	tween.parallel().tween_property(menu, ^'position:x', -2000, 0.3).from(0)
	await tween.finished
	State.transition_finish()
	menu.queue_free()

func _enter_tree() -> void:
	process_mode = ProcessMode.PROCESS_MODE_INHERIT if Engine.is_editor_hint() else ProcessMode.PROCESS_MODE_ALWAYS
	if not button: button = get_parent()
	if not menu: menu = owner
	if not scene: scene = FIRST_LEVEL
	if not button.text or button.text.is_empty(): button.text = 'Start'

func _ready() -> void:
	if Engine.is_editor_hint(): return
	if not scene: push_error('missing scene on %s' % get_path())
	if not button: push_error('missing button on %s' % get_path())
	if not menu: push_error('missing menu on %s' % get_path())
	button.pressed.connect(on_pressed)
