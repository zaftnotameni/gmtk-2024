class_name ForcesCurrentTime extends Node

@export var forced_current_time : float = -1

func _ready() -> void:
	if forced_current_time > 1: State.current_time = forced_current_time
