class_name Player extends CharacterBody2D

const GROUP := 'player'

@export var animator: AnimationPlayer

func _enter_tree() -> void:
	add_to_group('player')

static func tree() -> SceneTree: return Engine.get_main_loop()
static func all() -> Array: return tree().get_nodes_in_group(GROUP)
static func first() -> Player: return tree().get_first_node_in_group(GROUP)

func die() -> void:
	process_mode = PROCESS_MODE_DISABLED
	animator.play("die")
	await animator.animation_finished
	Checkpoint.current().spawn()
