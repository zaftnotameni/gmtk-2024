class_name WeakPoint extends Area2D

signal sig_weakpoint_hit()

const GROUP := 'weak_point'

func on_hook_stunner_hit_weakpoint(hook_pointy_bit:HookStunner):
	sig_weakpoint_hit.emit()
	print_verbose('weakpoint hit!')
	for snappy:PlayerControllerSnappy in PlayerControllerSnappy.all():
		if snappy.owner == hook_pointy_bit.owner: snappy.reset_grapple()

func on_area_entered(other:Area2D):
	if other is HookStunner: on_hook_stunner_hit_weakpoint(other)

func _enter_tree() -> void:
	add_to_group(GROUP)

func _ready() -> void:
	area_entered.connect(on_area_entered)

static func tree() -> SceneTree: return Engine.get_main_loop()
static func all() -> Array: return tree().get_nodes_in_group(GROUP)
static func first() -> Player: return tree().get_first_node_in_group(GROUP)
