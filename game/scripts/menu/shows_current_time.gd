class_name ShowsCurrentTime extends Node

var line_edit : LineEdit

func _enter_tree() -> void:
	process_mode = ProcessMode.PROCESS_MODE_INHERIT if Engine.is_editor_hint() else ProcessMode.PROCESS_MODE_ALWAYS
	if not line_edit: line_edit = get_parent()
	if not line_edit: line_edit = owner

func _ready() -> void:
	if not line_edit: push_error('missing line_edit on %s' % get_path())

func _process(_delta: float) -> void:
	if line_edit and State.current_time > 1:
		line_edit.text = string_format_time(State.current_time)

static func string_format_time(time_seconds: float) -> String:
	if time_seconds <= 0: return '--:--:--.---'
	var total_seconds = int(time_seconds)
	var milliseconds = int((time_seconds - total_seconds) * 1000)
	
	var seconds = total_seconds % 60
	@warning_ignore('integer_division')
	var minutes = (total_seconds / 60) % 60
	@warning_ignore('integer_division')
	var hours = total_seconds / 3600

	var formatted_time = "%02d:%02d:%02d.%03d" % [hours, minutes, seconds, milliseconds]
	
	return formatted_time
