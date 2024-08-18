class_name PathAutoFollow extends PathFollow2D

@export_group('configuration')
@export var speed : float = 0.05
@export var reverse : bool = false

func _physics_process(delta: float) -> void:
	progress_ratio += delta * speed * (-1 if reverse else 1)
	if progress_ratio < 0: progress_ratio = 1
	if progress_ratio > 1: progress_ratio = 0
