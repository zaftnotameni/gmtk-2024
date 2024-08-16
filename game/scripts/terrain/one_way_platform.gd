class_name OneWayPlatform extends StaticBody2D

func _ready() -> void:
	for c:Node in get_children():
		if c is CollisionShape2D:
			(c as CollisionShape2D).one_way_collision = true
