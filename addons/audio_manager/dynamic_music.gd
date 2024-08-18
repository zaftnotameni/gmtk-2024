extends AudioStreamPlayer

var previous_percentage: float = 0.0
var current: int = 0

func _process(delta: float) -> void:
	previous_percentage += PlayerControllerSnappy.get_chained_hooks_percentagae() * delta * 3.0
	previous_percentage -= delta * 0.1
	previous_percentage = clamp(previous_percentage, 0.0, 1.0)
	
	logic()
	
func logic() -> void:
	if !playing: return
	if !get_stream_playback(): return
	if previous_percentage > 0.75:
		if current == 3: return
		current = 3
		get_stream_playback().switch_to_clip(3)
		return
	if previous_percentage > 0.5:
		if current == 2: return
		current = 2
		get_stream_playback().switch_to_clip(2)
		return
	if previous_percentage > 0.2:
		if current == 1: return
		current = 1
		get_stream_playback().switch_to_clip(1)
		return
	if current == 0: return
	current = 0
	get_stream_playback().switch_to_clip(0)
