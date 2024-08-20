class_name MarkerLeft extends Marker2D

const GROUP := 'marker_left'

func _enter_tree() -> void:
	add_to_group(GROUP)

static func tree() -> SceneTree: return Engine.get_main_loop()
static func all() -> Array: return tree().get_nodes_in_group(GROUP)
static func first() -> MarkerLeft: return tree().get_first_node_in_group(GROUP)
