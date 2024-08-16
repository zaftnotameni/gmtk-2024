class_name ShowsAboutScreen extends Node

const ABOUT_SCREEN := preload('res://game/scenes/menu/screen/about_screen.tscn')

@export_group('optional')
@export var menu : Control
@export var scene : PackedScene
@export var button : BaseButton

func on_pressed():
	var instance : Control = scene.instantiate()
	menu.add_sibling(instance)
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_pause_mode(Tween.TweenPauseMode.TWEEN_PAUSE_PROCESS)
	tween.parallel().tween_property(menu, ^'position:x', -2000, 0.3).from(0)
	tween.parallel().tween_property(instance, ^'position:x', 0, 0.3).from(2000)
	instance.tree_exited.connect(button.grab_focus, CONNECT_ONE_SHOT)

func _enter_tree() -> void:
	process_mode = ProcessMode.PROCESS_MODE_INHERIT if Engine.is_editor_hint() else ProcessMode.PROCESS_MODE_ALWAYS
	if not button: button = get_parent()
	if not menu: menu = owner
	if not scene: scene = ABOUT_SCREEN
	if not button.text or button.text.is_empty(): button.text = 'Options'

func _ready() -> void:
	if not scene: push_error('missing scene on %s' % get_path())
	if not button: push_error('missing button on %s' % get_path())
	if not menu: push_error('missing menu on %s' % get_path())
	button.pressed.connect(on_pressed)
