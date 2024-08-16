class_name UnpausePresses extends Node

@export_group('optional')
@export var button : BaseButton

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('unpause'):
		get_viewport().set_input_as_handled()
		button.pressed.emit()

func _enter_tree() -> void:
	process_mode = ProcessMode.PROCESS_MODE_INHERIT if Engine.is_editor_hint() else ProcessMode.PROCESS_MODE_ALWAYS
	set_process_unhandled_input(false)
	if not button and get_parent() is BaseButton: button = get_parent()
	if not button and owner is BaseButton: button = owner
	if not button: push_error('missing button on %s' % get_path())

func _ready() -> void:
	if button:
		get_tree().create_timer(0.064).timeout.connect(set_process_unhandled_input.bind(true), CONNECT_ONE_SHOT)
