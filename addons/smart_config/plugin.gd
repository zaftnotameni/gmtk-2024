@tool
extends EditorPlugin

const CONFIG_AUTOLOAD_NAME := "Config"

func _enter_tree() -> void:
	add_autoload_singleton(CONFIG_AUTOLOAD_NAME, "./config.gd")

func _exit_tree() -> void:
	remove_autoload_singleton(CONFIG_AUTOLOAD_NAME)
