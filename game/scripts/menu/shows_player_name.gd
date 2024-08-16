class_name ShowsPlayerName extends Node

var line_edit : LineEdit
var player_name : String
var settings : ConfigFile = ConfigFile.new()

func _enter_tree() -> void:
	process_mode = ProcessMode.PROCESS_MODE_INHERIT if Engine.is_editor_hint() else ProcessMode.PROCESS_MODE_ALWAYS
	if not line_edit: line_edit = get_parent()
	if not line_edit: line_edit = owner

func _ready() -> void:
	if not line_edit: push_error('missing line_edit on %s' % get_path())
	SmartConfig.load_config(settings)
	player_name = settings.get_value('player', 'name', '')
	if line_edit and line_edit.text.is_empty() and player_name and not player_name.is_empty(): line_edit.text = player_name
