extends Node

@onready var path_to_follow : Path2D = %Path2D
@onready var path_to_follow2 : Path2D = %Path2D2


var scene := load('res://game/scenes/terrain/roamer.tscn')

var num_paths : float = 20

func _ready() -> void:
	for i in num_paths:
		var pf := PathFollow2D.new()
		var pf2 := PathFollow2D.new()
		pf.rotates = false
		pf2.rotates = false
		var instance : Roamer = scene.instantiate()
		var instance2 : Roamer = scene.instantiate()
		instance.direction = -1
		instance.roaming_mode = Roamer.RoamerMode.MANUAL
		instance2.direction = -1
		instance2.roaming_mode = Roamer.RoamerMode.MANUAL
		pf.add_child(instance)
		pf2.add_child(instance2)
		path_to_follow.add_child.call_deferred(pf)
		path_to_follow2.add_child.call_deferred(pf2)
		await pf.ready
		await pf2.ready
		pf.progress_ratio = i * (1.0 / (num_paths + 1.0))
		pf2.progress_ratio = i * (1.0 / (num_paths + 1.0))

func _physics_process(delta: float) -> void:
	for pf:PathFollow2D in path_to_follow.get_children():
		pf.progress_ratio += delta / 100.0
		if pf.progress_ratio > 1:
			pf.progress_ratio = 0
	for pf:PathFollow2D in path_to_follow2.get_children():
		pf.progress_ratio += delta / 100.0
		if pf.progress_ratio > 1:
			pf.progress_ratio = 0
