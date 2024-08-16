class_name LocalStorageBridge extends RefCounted

static func is_on_web() -> bool: return OS.has_feature('web')

static func local_storage_set_item(key:String, value:String) -> void:
	if not is_on_web(): return
	JavaScriptBridge.eval('localStorage.setItem(`%s`, `%s`)' % [key, value])

static func local_storage_get_item(key:String) -> String:
	if not is_on_web(): return ""
	var existing := JavaScriptBridge.eval('localStorage.getItem(`%s`) || ""' % [key]) as String
	if existing: return existing
	else: return ""

static func local_storage_get_or_set_item(key:String, default_value:String) -> String:
	if not is_on_web(): return ""
	var existing := local_storage_get_item(key) as String
	if existing and not existing.is_empty(): return existing
	else:
		local_storage_set_item(key, default_value)
		return default_value

static func local_storage_set_config_file(key:String, cfg:ConfigFile) -> ConfigFile:
	local_storage_set_item(key, cfg.encode_to_text())
	return cfg

static func local_storage_get_config_file(key:String, cfg:ConfigFile) -> ConfigFile:
	if not is_on_web(): return cfg
	var existing := local_storage_get_item(key) as String
	if existing and not existing.is_empty(): cfg.parse(existing)
	return cfg

static func local_storage_get_or_set_config_file(key:String, cfg:ConfigFile) -> ConfigFile:
	if not is_on_web(): return cfg
	var existing := local_storage_get_item(key) as String
	if existing and not existing.is_empty():
		cfg.parse(existing)
		return cfg
	else:
		local_storage_set_item(key, cfg.encode_to_text())
		return cfg
	
