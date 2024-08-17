class_name LevelGoal extends Area2D

@export var next_level : PackedScene

func _enter_tree() -> void:
	collision_mask = 2 # player_body
	collision_layer = 128 # level_goal

func go_to_next_level():
	if not next_level: return
	var instance : Node2D = next_level.instantiate()
	if not instance: return
	State.transition_start()
	instance.z_index = -1
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_pause_mode(Tween.TweenPauseMode.TWEEN_PAUSE_PROCESS)
	tween.bind_node(Layers.game)
	for p:Player in Player.all():
		p.process_mode = Node.PROCESS_MODE_DISABLED
		tween.parallel().tween_property(p, ^'position:y', -2000, 0.3).as_relative()
	tween.parallel().tween_property(owner, ^'position:y', 2000, 0.3).as_relative()
	await tween.finished

	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_pause_mode(Tween.TweenPauseMode.TWEEN_PAUSE_PROCESS)
	tween.bind_node(Layers.game)
	tween.tween_callback(State.mark_as_game).set_delay(0.1)
	tween.tween_callback(State.transition_finish).set_delay(0.1)
	tween.tween_callback(Checkpoint.current().spawn).set_delay(0.2)

	owner.queue_free()
	owner.add_sibling.call_deferred(instance)

func on_body_entered(body:Node2D):
	if body is Player: go_to_next_level()

func _ready() -> void:
	if not next_level: push_error('must have a next_level %s' % get_path())
	if get_child_count() <= 0:
		spawn_default_children.call_deferred()
	body_entered.connect(on_body_entered)

func spawn_default_children():
	var col := CollisionShape2D.new()
	var boundary := WorldBoundaryShape2D.new()
	boundary.normal = Vector2.DOWN
	col.shape = boundary
	add_child(col)
