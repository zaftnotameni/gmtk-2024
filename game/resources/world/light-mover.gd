class_name LightMover
extends Node

@export var advance_amount_rotation = 0.1
@export var advance_amount_energy = -0.001
@export var start_rotation: float = 0.0
@export var end_rotation: float = 10
@export var start_energy: float = 1.0
@export var end_energy: float = 0.0
@export var move_time: float = 5.0

func _ready() -> void:
	get_parent().rotation_degrees = start_rotation
	var energy_tween: Tween = create_tween().set_loops().set_trans(Tween.TRANS_LINEAR)
	energy_tween.tween_callback(advance).set_delay(0.01)


func advance():
	if round(get_parent().rotation_degrees) == end_rotation:
		get_parent().rotation_degrees = start_rotation
		get_parent().energy = start_energy
	get_parent().rotation_degrees += advance_amount_rotation
	get_parent().energy += advance_amount_energy
