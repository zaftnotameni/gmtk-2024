class_name AtBackground extends Node

@export var scene : PackedScene

func _enter_tree() -> void:
	if not scene: push_error('must provide a scene %s' % get_path())
	GameManagerLayers.layer_background().add_child.call_deferred(scene.instantiate())
