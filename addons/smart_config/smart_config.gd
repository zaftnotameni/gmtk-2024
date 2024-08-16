class_name SmartConfig extends RefCounted

const LOCAL_STORAGE_KEY := 'smart_config'
const FILE_PATH := 'user://smart_config.cfg'

static func load_config_from_local_storage(cfg:ConfigFile=ConfigFile.new()) -> ConfigFile:
	if not OS.has_feature('web'):
		push_error('should only be called on web')
		return cfg
	return LocalStorageBridge.local_storage_get_config_file(LOCAL_STORAGE_KEY, cfg)

static func load_config_from_file(cfg:ConfigFile=ConfigFile.new()) -> ConfigFile:
	if not FileAccess.file_exists(FILE_PATH):
		push_error('missing config file')
		return cfg
	cfg.load(FILE_PATH)
	return cfg

static func save_config_to_local_storage(cfg:ConfigFile=ConfigFile.new()) -> ConfigFile:
	if not OS.has_feature('web'):
		push_error('should only be called on web')
		return cfg
	return LocalStorageBridge.local_storage_set_config_file(LOCAL_STORAGE_KEY, cfg)

static func save_config_to_file(cfg:ConfigFile=ConfigFile.new()) -> ConfigFile:
	cfg.save(FILE_PATH)
	return cfg

static func load_config(cfg:ConfigFile=ConfigFile.new()) -> ConfigFile:
	if OS.has_feature('web'):
		return load_config_from_local_storage(cfg)
	else:
		return load_config_from_file(cfg)

static func save_config(cfg:ConfigFile=ConfigFile.new()) -> ConfigFile:
	print_verbose(cfg.encode_to_text())
	if OS.has_feature('web'):
		return save_config_to_local_storage(cfg)
	else:
		return save_config_to_file(cfg)
