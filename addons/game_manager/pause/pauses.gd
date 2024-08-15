class_name Pauses extends Node

@export var unpauses_on_exit : bool = false

func _enter_tree() -> void:
	process_mode = ProcessMode.PROCESS_MODE_INHERIT if Engine.is_editor_hint() else ProcessMode.PROCESS_MODE_ALWAYS
	get_tree().paused = true

func _exit_tree() -> void:
	if unpauses_on_exit: get_tree().paused = false
