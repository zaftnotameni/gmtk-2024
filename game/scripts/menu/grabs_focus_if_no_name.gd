class_name GrabsFocusIfNoName extends Node

@export_group('optional')
@export var control : Control

func _enter_tree() -> void:
	process_mode = ProcessMode.PROCESS_MODE_INHERIT if Engine.is_editor_hint() else ProcessMode.PROCESS_MODE_ALWAYS
	if not control and get_parent() is Control: control = get_parent()
	if not control and owner is Control: control = owner
	if not control: push_error('missing control on %s' % get_path())

func _ready() -> void:
	var player_name := Config.settings.get_value('player', 'name', '') as String
	if not player_name or player_name.is_empty():
		if control:
			get_tree().create_timer(0.064).timeout.connect(control.grab_focus, CONNECT_ONE_SHOT)
