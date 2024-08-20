class_name BossLevelScript extends Node

@onready var boss : Node2D = %Boss
@onready var layer : TileMapLayer = %ForegroundTilemap
@onready var spots : Node2D = %HookSpots

var tween : Tween

func prepare_tween() -> Tween:
	if tween and tween.is_running(): tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_pause_mode(Tween.TweenPauseMode.TWEEN_PAUSE_PROCESS)
	tween.bind_node(Layers.game)
	tree_exiting.connect(tween.kill)
	return tween

func on_boss_dead():
	prepare_tween()
	for spot:Marker2D in spots.get_children():
		var local_pos := layer.to_local(spot.global_position)
		var coords := layer.local_to_map(local_pos)
		tween.tween_callback(layer.set_cell.bind(Vector2(coords.x, coords.y), 1, Vector2(0, 0), 2))
		tween.tween_interval(0.3)
	await tween.finished

func _ready() -> void:
	boss.tree_exited.connect(on_boss_dead)
	$AnimationPlayer.play("a")
