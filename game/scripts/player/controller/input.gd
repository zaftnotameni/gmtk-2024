class_name PlayerInput extends Node

static func xy_normalized() -> Vector2:
	return Input.get_vector('player_left', 'player_right', 'player_up', 'player_down')

static func is_grapple(event:InputEvent) -> bool:
	return event and event.is_action_pressed('grapple')

static func is_respawn(event:InputEvent) -> bool:
	return event and event.is_action_pressed('respawn')
