class_name Hazard extends Area2D


func _ready() -> void:
	body_entered.connect(_body_entered)


func _body_entered(body: Node2D) -> void:
	if body is Player:
		body.die()
