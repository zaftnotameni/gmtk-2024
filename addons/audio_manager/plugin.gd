@tool
extends EditorPlugin

const AUDIO_MANAGER_AUTOLOAD_NAME := "AudioManager"

func _enter_tree() -> void:
	add_autoload_singleton(AUDIO_MANAGER_AUTOLOAD_NAME, "./audio_manager.tscn")

func _exit_tree() -> void:
	remove_autoload_singleton(AUDIO_MANAGER_AUTOLOAD_NAME)
