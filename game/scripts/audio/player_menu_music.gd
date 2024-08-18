class_name PlaysMenuMusic extends Node

func _ready() -> void:
	AudioManager.bgm_levels_dynamic.stop()
	AudioManager.play_bgm(AudioManager.bgm_title)

func _exit_tree() -> void:
	AudioManager.bgm_title.stop()
	AudioManager.play_bgm(AudioManager.bgm_levels_dynamic)
