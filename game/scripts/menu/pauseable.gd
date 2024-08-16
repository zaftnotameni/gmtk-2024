class_name Pauseable extends Node

const PAUSE_SCREEN := preload('res://game/scenes/menu/screen/pause_screen.tscn')

@export_category('optional')
@export var target : Node
@export var scene : PackedScene

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('pause'):
		get_viewport().set_input_as_handled()
		set_process_unhandled_input(false)
		on_pause()

func on_pause():
	var instance : Control = scene.instantiate()
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	Layers.menu.add_child.call_deferred(instance)
	tween.set_pause_mode(Tween.TweenPauseMode.TWEEN_PAUSE_PROCESS)
	tween.parallel().tween_property(instance, ^'position:y', 0, 0.3).from(2000)
	instance.tree_exited.connect(set_process_unhandled_input.bind(true))

func _enter_tree() -> void:
	process_mode = ProcessMode.PROCESS_MODE_INHERIT if Engine.is_editor_hint() else ProcessMode.PROCESS_MODE_ALWAYS
	if not target: target = get_parent()
	if not scene: scene = PAUSE_SCREEN
	target.process_mode = Node.PROCESS_MODE_INHERIT

func _ready() -> void:
	if not scene: push_error('missing scene on %s' % get_path())
