extends Node2D

@onready var l : Sprite2D = $L
@onready var r : Sprite2D = $R
@onready var h : Sprite2D = $H

func _unhandled_input(event: InputEvent) -> void:
	var ek = event as InputEventKey
	if not ek: return
	if not ek.is_pressed(): return
	if ek.keycode == KEY_W:
		h.global_position = r.global_position + Vector2(0, -100)
		l.global_position = h.global_position + Vector2(0, -100)
	if ek.keycode == KEY_A:
		h.global_position = r.global_position + Vector2(-100, 0)
		l.global_position = h.global_position + Vector2(-100, 0)
	if ek.keycode == KEY_S:
		h.global_position = r.global_position + Vector2(0, 100)
		l.global_position = h.global_position + Vector2(0, 100)
	if ek.keycode == KEY_D:
		h.global_position = r.global_position + Vector2(100, 0)
		l.global_position = h.global_position + Vector2(100, 0)
	if ek.keycode == KEY_UP:
		h.global_position = l.global_position + Vector2(0, -100)
		r.global_position = h.global_position + Vector2(0, -100)
	if ek.keycode == KEY_LEFT:
		h.global_position = l.global_position + Vector2(-100, 0)
		r.global_position = h.global_position + Vector2(-100, 0)
	if ek.keycode == KEY_DOWN:
		h.global_position = l.global_position + Vector2(0, 100)
		r.global_position = h.global_position + Vector2(0, 100)
	if ek.keycode == KEY_RIGHT:
		h.global_position = l.global_position + Vector2(100, 0)
		r.global_position = h.global_position + Vector2(100, 0)
