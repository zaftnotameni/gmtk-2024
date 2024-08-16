class_name SubmitPresses extends Node

@export_group('optional')
@export var button : BaseButton

func _unhandled_input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if not button: return
	if not key_event: return
	if not get_viewport().gui_get_focus_owner(): return
	if not get_viewport().gui_get_focus_owner() is LineEdit: return
	if key_event.is_action('submit'):
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
		get_tree().create_timer(0.3).timeout.connect(set_process_unhandled_input.bind(true), CONNECT_ONE_SHOT)
