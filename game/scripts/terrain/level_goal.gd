class_name LevelGoal extends Area2D

@export var next_level : PackedScene

func _ready() -> void:
	if not next_level: push_error('must have a next_level %s' % get_path())
	if get_child_count() <= 0:
		spawn_default_children.call_deferred()

func spawn_default_children():
	var col := CollisionShape2D.new()
	var boundary := WorldBoundaryShape2D.new()
	boundary.normal = Vector2.DOWN
	col.shape = boundary
	add_child(col)
