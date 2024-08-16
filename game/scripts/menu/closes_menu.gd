class_name ClosesMenu extends Node

@export_group('optional')
@export var menu : Control
@export var button : BaseButton

func on_pressed():
	var previous : Control

	for child in menu.get_parent().get_children():
		if child is Control and child != menu: previous = child

	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_pause_mode(Tween.TweenPauseMode.TWEEN_PAUSE_PROCESS)
	tween.parallel().tween_property(menu, ^'position:x', 2000, 0.3).from(0)
	if previous: tween.parallel().tween_property(previous, ^'position:x', 0, 0.3).from(-2000)
	await tween.finished
	menu.queue_free()

func _enter_tree() -> void:
	process_mode = ProcessMode.PROCESS_MODE_INHERIT if Engine.is_editor_hint() else ProcessMode.PROCESS_MODE_ALWAYS
	if not button: button = get_parent()
	if not menu: menu = owner
	if not button.text or button.text.is_empty(): button.text = 'Back'

func _ready() -> void:
	if not button: push_error('missing button on %s' % get_path())
	if not menu: push_error('missing menu on %s' % get_path())
	button.pressed.connect(on_pressed)
