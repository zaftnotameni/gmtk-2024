class_name AtHUD extends Node

@export var scene : PackedScene

var spawned : Array[Node] = []

func _exit_tree() -> void:
	for n:Node in spawned:
		if n and not n.is_queued_for_deletion(): n.queue_free()

func _enter_tree() -> void:
	if not scene: push_error('must provide a scene %s' % get_path())
	var node := scene.instantiate()
	spawned.push_back(node)
	node.tree_exiting.connect(spawned.erase.bind(node))
	GameManagerLayers.layer_hud().add_child.call_deferred(node)
