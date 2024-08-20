class_name MarkerRight extends Marker2D

const GROUP := 'marker_right'

func _enter_tree() -> void:
	add_to_group(GROUP)

static func tree() -> SceneTree: return Engine.get_main_loop()
static func all() -> Array: return tree().get_nodes_in_group(GROUP)
static func first() -> MarkerRight: return tree().get_first_node_in_group(GROUP)
