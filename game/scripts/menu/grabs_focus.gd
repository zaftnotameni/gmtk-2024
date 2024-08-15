class_name GrabsFocus extends Node

@export_group('optional')
@export var button : BaseButton

func _enter_tree() -> void:
	process_mode = ProcessMode.PROCESS_MODE_INHERIT if Engine.is_editor_hint() else ProcessMode.PROCESS_MODE_ALWAYS
	if not button and get_parent() is BaseButton: button = get_parent()
	if not button and owner is BaseButton: button = owner
	if not button: push_error('missing button on %s' % get_path())

func _ready() -> void:
	if button:
		get_tree().create_timer(0.064).timeout.connect(button.grab_focus, CONNECT_ONE_SHOT)
