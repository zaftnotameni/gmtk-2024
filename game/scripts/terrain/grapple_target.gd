class_name GrappleTarget extends Area2D

func _ready() -> void:
	if get_child_count() <= 0:
		spawn_default_children.call_deferred()

func spawn_default_children():
	var col := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 8
	col.shape = circle
	add_child(col)
