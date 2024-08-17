extends Node2D

func _ready() -> void:
	var bg := $Background as Node2D
	if bg:
		for c in bg.get_children():
			var parallax := c as Parallax2D
			if not parallax: continue
			parallax.autoscroll.y = 500
