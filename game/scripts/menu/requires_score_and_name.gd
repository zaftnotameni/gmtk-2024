class_name RequiresScoreAndName extends Node

@export_group('optional')
@export var name_input : LineEdit
@export var score_input : LineEdit
@export var button : BaseButton

func _enter_tree() -> void:
	process_mode = ProcessMode.PROCESS_MODE_INHERIT if Engine.is_editor_hint() else ProcessMode.PROCESS_MODE_ALWAYS

func _ready() -> void:
	if not name_input: name_input = %NameInput
	if not score_input: score_input = %ScoreInput
	if not button and get_parent() is BaseButton: button = get_parent()
	if not button and owner is BaseButton: button = owner
	if not button.text or button.text.is_empty(): button.text = 'Back'
	if not button: push_error('missing button on %s' % get_path())
	if not name_input: push_error('missing name_input on %s' % get_path())
	if not score_input: push_error('missing score_input on %s' % get_path())

func _process(_delta: float) -> void:
	if (
		name_input and name_input.text and not name_input.text.is_empty() and
		score_input and score_input.text and not score_input.text.is_empty()
	):
		button.disabled = false
		button.remove_meta('prevent_submit')
	else:
		button.disabled = true
		button.set_meta('prevent_submit', true)
