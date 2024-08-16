class_name CancelsScore extends Node

@export_group('optional')
@export var menu : Control
@export var button : BaseButton

func on_pressed():
	if not button: return

	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_pause_mode(Tween.TweenPauseMode.TWEEN_PAUSE_PROCESS)
	tween.tween_property(menu, ^'position:x', 2000, 0.3).from_current()
	await tween.finished

	menu.queue_free()

func _enter_tree() -> void:
	process_mode = ProcessMode.PROCESS_MODE_INHERIT if Engine.is_editor_hint() else ProcessMode.PROCESS_MODE_ALWAYS

func _ready() -> void:
	if not menu: menu = owner
	if not button and get_parent() is BaseButton: button = get_parent()
	if not button and owner is BaseButton: button = owner
	if not button.text or button.text.is_empty(): button.text = 'Submit Score'
	if not menu: push_error('missing menu on %s' % get_path())
	if not button: push_error('missing button on %s' % get_path())
	button.pressed.connect(on_pressed)
