extends AudioStreamPlayer

var percentage: float = 0.0

func _process(delta: float) -> void:
	percentage += PlayerControllerSnappy.get_chained_hooks_percentagae() * delta * 3.0
	percentage -= delta * 0.1
	percentage = clamp(percentage, 0.0, 1.0)
	#print(percentage)

func _play(from_position: float = 0.0) -> void:
	unmute(0)
	$Timer.start()
	
func _stop():
	$Timer.stop()

func _on_timer_timeout() -> void:
	if !playing: return
	if percentage > 0.75:
		unmute(0)
		return
	if percentage > 0.5:
		unmute(1)
		return
	if percentage > 0.2:
		unmute(2)
		return
	unmute(3)


func unmute(index: int) -> void:
	for i in stream.stream_count:
		if i == index: continue
		stream.set_sync_stream_volume(i, -60.0)
	stream.set_sync_stream_volume(index, 0.0)
