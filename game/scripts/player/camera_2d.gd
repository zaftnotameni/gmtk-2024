extends Camera2D

func _ready() -> void:
	limit_left = int(MarkerLeft.first().position.x)
	limit_right = int(MarkerRight.first().position.x)
