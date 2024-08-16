class_name Player extends CharacterBody2D

const GROUP := 'player'

func _enter_tree() -> void:
	add_to_group('player')

static func tree() -> SceneTree: return Engine.get_main_loop()
static func all() -> Array: return tree().get_nodes_in_group(GROUP)
static func first() -> Player: return tree().get_first_node_in_group(GROUP)
