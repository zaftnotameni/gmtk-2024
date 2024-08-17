class_name LevelGoal extends Area2D

@export var next_level : PackedScene
@export var transition_scene : PackedScene

var tween : Tween

func _enter_tree() -> void:
	collision_mask = 2 # player_body
	collision_layer = 128 # level_goal
	if not transition_scene : transition_scene = load('res://game/scenes/transition/transition_screen.tscn')

func prepare_tween() -> Tween:
	if tween and tween.is_running(): tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_pause_mode(Tween.TweenPauseMode.TWEEN_PAUSE_PROCESS)
	tween.bind_node(Layers.game)
	return tween

func go_to_next_level():
	if not next_level: return
	if not transition_scene: return
	var instance : Node2D = next_level.instantiate()
	var transition : Node2D = transition_scene.instantiate()
	if not instance: return
	if not transition: return

	State.transition_start()
	instance.z_index = -1

	owner.add_sibling(transition)

	for p:Player in Player.all():
		p.process_mode = Node.PROCESS_MODE_DISABLED
		p.queue_free()

	prepare_tween()
	tween.tween_property(owner, ^'position:y', 2000, 0.3).as_relative()
	tween.parallel().tween_property(transition, ^'position:y', 0, 0.3).from(2000)
	tween.parallel().tween_callback(owner.hide).set_delay(0.1)

	tween.tween_property(transition.get_node('Sprite2D'), ^'position:y', -2000, 0.3).as_relative()
	tween.parallel().tween_property(transition, ^'position:y', 2000, 0.3).as_relative()

	await tween.finished

	prepare_tween()
	tween.tween_callback(owner.queue_free)
	tween.parallel().tween_callback(owner.add_sibling.bind(instance))
	tween.tween_callback(State.mark_as_game).set_delay(0.1)
	tween.tween_callback(State.transition_finish).set_delay(0.1)
	tween.tween_callback(transition.queue_free).set_delay(0.1)

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
