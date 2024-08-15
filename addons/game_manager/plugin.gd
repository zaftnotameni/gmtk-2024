@tool
extends EditorPlugin

const LAYERS_AUTOLOAD_NAME := "Layers"
const STATE_AUTOLOAD_NAME := "State"

func _enter_tree() -> void:
	add_autoload_singleton(LAYERS_AUTOLOAD_NAME, "./layers.tscn")
	add_autoload_singleton(STATE_AUTOLOAD_NAME, "./state.gd")

func _exit_tree() -> void:
	remove_autoload_singleton(LAYERS_AUTOLOAD_NAME)
	remove_autoload_singleton(STATE_AUTOLOAD_NAME)
