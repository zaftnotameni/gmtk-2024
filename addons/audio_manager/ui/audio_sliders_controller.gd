extends Node

@onready var values := [%MasterValue, %BGMValue, %SFXValue, %UIValue]
@onready var sliders := [%MasterSlider, %BGMSlider, %SFXSlider, %UISlider]

func on_value_changed(new_value:float, index:int):
	AudioManager.set_volume_linear_0_100(index, new_value, sliders[index], values[index])
	AudioManager.play_volume_tick_sound(index)

func _ready() -> void:
	sliders[0].grab_focus()
	for index:int in AudioManagerScene.AudioBus.values():
		if index < 0: continue
		AudioManager.get_volume_linear_0_100(index, sliders[index], values[index])
		sliders[index].value_changed.connect(on_value_changed.bind(index))

# for future reference: https://forum.godotengine.org/t/looking-for-a-slider-theme-tutorial/25351/2
# Icons
# 
# Grabber
# — Drag and drop a pre-sized custom image to use for the slider knob here.
# 
# Grabber Highlight
# — Drag and drop the same pre-sized custom image to use for the slider knob here.
# 
# Styles
# 
# Grabber Area
# — Create a new StyleBoxFlat
# — Set desired Bg Color
# 
# Slider
# — Create a new StyleBoxFlat
# — Set desired Bg Color
# — Set Content Margin
# ----- Set a Top value
# ----- Set a Bottom value (Top and bottom values combined determine overall thickness of the control)
