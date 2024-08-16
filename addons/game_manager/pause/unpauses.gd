class_name Unpauses extends Node

@export var pauses_on_exit : bool = false

func _enter_tree() -> void:
	process_mode = ProcessMode.PROCESS_MODE_INHERIT if Engine.is_editor_hint() else ProcessMode.PROCESS_MODE_ALWAYS

func _ready() -> void:
	unpause.call_deferred()

func unpause():
	get_tree().paused = false

func _exit_tree() -> void:
	if pauses_on_exit: get_tree().paused = true
