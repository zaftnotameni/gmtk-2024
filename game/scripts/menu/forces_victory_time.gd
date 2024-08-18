class_name ForcesVictoryTime extends Node

@export var forced_victory_time : float = 90000

func _ready() -> void:
	if forced_victory_time > 1: State.victory_time = forced_victory_time
