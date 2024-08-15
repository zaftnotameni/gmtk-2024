class_name AudioManagerScene extends Node

enum AudioBus { Any = -1, Master = 0, BGM = 1, SFX = 2, UI = 3 }

signal sig_volume_changed(which_bus:AudioBus, volume_linear_0_100:float)

@onready var master_test_sound : AudioStreamPlayer = $Master/TestSound
@onready var bgm_test_sound : AudioStreamPlayer = $BGM/TestSound
@onready var sfx_test_sound : AudioStreamPlayer = $SFX/TestSound
@onready var ui_test_sound : AudioStreamPlayer = $UI/TestSound
@onready var ui_focus : AudioStreamPlayer = $UI/Focus
@onready var ui_press : AudioStreamPlayer = $UI/Press

var settings : ConfigFile = ConfigFile.new()
var ignore = {}
var playing = {}

func play_master(player:AudioStreamPlayer, only_if_not_playing:bool=true): return play_stream(player, AudioBus.Master, only_if_not_playing)
func play_bgm(player:AudioStreamPlayer, only_if_not_playing:bool=true): return play_stream(player, AudioBus.BGM, only_if_not_playing)
func play_sfx(player:AudioStreamPlayer, only_if_not_playing:bool=true): return play_stream(player, AudioBus.SFX, only_if_not_playing)
func play_ui(player:AudioStreamPlayer, only_if_not_playing:bool=true): return play_stream(player, AudioBus.UI, only_if_not_playing)

func play_stream(player:AudioStreamPlayer, bus:AudioBus=AudioBus.Any, only_if_not_playing:bool=true):
	if not player: return
	if not player.stream: return
	if player.playing and only_if_not_playing: return

	var id := id_of(player)
	if ignore.get_or_add(id, 0) < 0: ignore[id] = 0
	if ignore.get_or_add(id, 0) > 0: ignore[id] = ignore.get_or_add(id, 0) - 1
	if ignore.get_or_add(id, 0) > 0: print_verbose('ignored: ' + id); return
	
	if bus != AudioBus.Any: player.bus = AudioBus.find_key(bus)

	if player.bus == AudioBus.find_key(AudioBus.BGM):
		if player.name != 'TestSound':
			player.set('parameters/looping', true)
			player.playback_type = AudioServer.PLAYBACK_TYPE_STREAM

	print_verbose('play: %s' % id)
	player.play()

func ignore_next(player:AudioStreamPlayer, how_many:int=1):
	if not player: return
	if not player.stream: return

	var id := id_of(player)
	ignore[id] = ignore.get_or_add(id, 0) + how_many

func id_of(player:AudioStreamPlayer) -> String: return '%s__%s' % [player.bus, player.stream.resource_path]

func from_config_to_audio_server():
	if Engine.is_editor_hint(): return
	SmartConfig.load_config(settings)
	set_volume_linear_0_100(AudioBus.Master, settings.get_value('audio', 'audio_master_volume_linear_0_100', 50.0), null, null, true)
	set_volume_linear_0_100(AudioBus.BGM, settings.get_value('audio', 'audio_bgm_volume_linear_0_100', 50.0), null, null, true)
	set_volume_linear_0_100(AudioBus.SFX, settings.get_value('audio', 'audio_sfx_volume_linear_0_100', 50.0), null, null, true)
	set_volume_linear_0_100(AudioBus.UI, settings.get_value('audio', 'audio_ui_volume_linear_0_100', 50.0), null, null, true)

func from_audio_server_to_config():
	if Engine.is_editor_hint(): return
	settings.set_value('audio', 'audio_master_volume_linear_0_100', get_volume_linear_0_100(AudioBus.Master))
	settings.set_value('audio', 'audio_bgm_volume_linear_0_100', get_volume_linear_0_100(AudioBus.BGM))
	settings.set_value('audio', 'audio_sfx_volume_linear_0_100', get_volume_linear_0_100(AudioBus.SFX))
	settings.set_value('audio', 'audio_ui_volume_linear_0_100', get_volume_linear_0_100(AudioBus.UI))
	SmartConfig.save_config(settings)

func _enter_tree() -> void:
	from_config_to_audio_server()

func update_ui(volume_linear_0_100:float, slider:Slider=null, label:Label=null):
	if slider: slider.value = volume_linear_0_100
	if label: label.text = str(roundi(volume_linear_0_100))

func set_volume_linear_0_100(which_bus:AudioBus, volume_linear_0_100:float, slider:Slider=null, label:Label=null, skip_update_from_audio_server:=false):
	AudioServer.set_bus_volume_db(which_bus, linear_to_db(volume_linear_0_100 / 100.0))
	update_ui(volume_linear_0_100, slider, label)
	if not skip_update_from_audio_server: from_audio_server_to_config()
	sig_volume_changed.emit(which_bus, volume_linear_0_100)

func get_volume_linear_0_100(which_bus:AudioBus, slider:Slider=null, label:Label=null) -> float:
	var volume_db := AudioServer.get_bus_volume_db(which_bus)
	var volume_linear_0_100 : float = db_to_linear(volume_db) * 100.0
	update_ui(volume_linear_0_100, slider, label)
	return volume_linear_0_100

func play_volume_tick_sound(which_bus:AudioBus):
	match which_bus:
		AudioBus.Master: play_master(ui_test_sound)
		AudioBus.BGM: play_bgm(bgm_test_sound)
		AudioBus.SFX: play_sfx(sfx_test_sound)
		AudioBus.UI: play_ui(ui_test_sound)
