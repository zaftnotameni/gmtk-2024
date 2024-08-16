extends Node

static var settings : ConfigFile = ConfigFile.new()

static func _static_init() -> void:
	SmartConfig.load_config(settings)
	print_verbose('loading config:\n%s' % settings.encode_to_text())

func save_settings() -> void:
	SmartConfig.save_config(settings)
