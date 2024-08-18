class_name StateMenu extends Node

@export var wipe_state_stack : bool = false

func _enter_tree() -> void:
	process_mode = ProcessMode.PROCESS_MODE_INHERIT if Engine.is_editor_hint() else ProcessMode.PROCESS_MODE_ALWAYS

func _exit_tree() -> void:
	State.pop_menu()

func _ready() -> void:
	if wipe_state_stack:
		State.mark_as_menu()
	else:
		State.push_menu()
