class_name Unpauseable extends Node

@export_category('optional')
@export var target : Node

func _enter_tree() -> void:
	process_mode = ProcessMode.PROCESS_MODE_INHERIT if Engine.is_editor_hint() else ProcessMode.PROCESS_MODE_ALWAYS
	if not target: target = get_parent()
	target.process_mode = process_mode
