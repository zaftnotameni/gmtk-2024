class_name PlaysMenuMusic extends Node

func _ready() -> void:
	AudioManager.play_bgm(AudioManager.bgm_title)

func _exit_tree() -> void:
	AudioManager.bgm_title.stop()
