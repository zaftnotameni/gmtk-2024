class_name LevelGoal extends Area2D

@export var next_level : PackedScene

var tween : Tween

func _enter_tree() -> void:
	collision_mask = 2 # player_body
	collision_layer = 128 # level_goal

func prepare_tween() -> Tween:
	if tween and tween.is_running(): tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_pause_mode(Tween.TweenPauseMode.TWEEN_PAUSE_PROCESS)
	tween.bind_node(Layers.game)
	return tween

func go_to_next_level():
	if not next_level: return

	# prepare instance for next level
	var instance : Node2D = next_level.instantiate()

	# remove current player
	for p:Player in Player.all():
		p.process_mode = Node.PROCESS_MODE_DISABLED
		p.queue_free()

	# add next level to the tree and remove the current one
	owner.add_sibling.call_deferred(instance)
	owner.queue_free()

	prepare_tween()
	# mark the game as in "game" mode again
	tween.tween_callback(State.mark_as_game).set_delay(0.1)


func on_body_entered(body:Node2D):
	if body is Player:
		await body.ascend()
		go_to_next_level()


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
