class_name PressBlip extends Node

@export_group('optional')
@export var button : BaseButton

func on_pressed():
	AudioManager.play_ui(AudioManager.ui_press)

func _enter_tree() -> void:
	process_mode = ProcessMode.PROCESS_MODE_INHERIT if Engine.is_editor_hint() else ProcessMode.PROCESS_MODE_ALWAYS
	if not button and get_parent() is BaseButton: button = get_parent()
	if not button and owner is BaseButton: button = owner
	if not button: push_error('missing button on %s' % get_path())

func _ready() -> void:
	if button:
		button.pressed.connect(on_pressed)
