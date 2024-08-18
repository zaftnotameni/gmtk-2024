extends Label

@onready var color_rect = $ColorRect

var tween : Tween

func _ready() -> void:
	self.position = self.position.snapped(Vector2(16, 16))
	color_rect.size = get_rect().size
	color_rect.position = Vector2.ZERO
	var off := get_rect().size.x
	scale.x = 0

	await Checkpoint.current().sig_spawn_animation_finished

	prepare_tween()
	tween.tween_property(self, 'scale:x', 1.0, 1.0).from(0.0)
	tween.tween_property(color_rect, 'offset_left', off, 1.0).from(0.0)
	tween.tween_property(color_rect, 'scale:x', 0.0, 0.0)
	tween.tween_property(color_rect, 'offset_left', 0.0, 0.0)
	tween.tween_interval(2.0)
	tween.tween_property(color_rect, 'scale:x', 1.0, 1.0)
	tween.tween_property(self, 'scale:x', 0.0, 1.0)

	await tween.finished
	queue_free()

func prepare_tween() -> Tween:
	if tween and tween.is_running(): tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_pause_mode(Tween.TweenPauseMode.TWEEN_PAUSE_PROCESS)
	tween.bind_node(Layers.game)
	tree_exiting.connect(tween.kill)
	return tween
