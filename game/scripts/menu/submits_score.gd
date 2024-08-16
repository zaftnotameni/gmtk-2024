class_name SubmitsScore extends Node

@export_group('optional')
@export var menu : Control
@export var button : BaseButton
@export var name_input : LineEdit
@export var score_input : LineEdit

func on_pressed():
	if not button: return
	if not name_input: return
	if not score_input: return
	if State.current_time < 1: return
	if button.get_meta('prevent_submit', false): return

	var previous_text = button.text
	button.text = 'Submitting Score...'
	button.disabled = true
	name_input.editable = false

	var success := await Leaderboards.post_guest_score(SmartQuiver.default_leaderboard_id, State.current_time, name_input.text)

	if not success: return

	Config.settings.set_value('player', 'name', name_input.text)
	Config.save_settings()

	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_pause_mode(Tween.TweenPauseMode.TWEEN_PAUSE_PROCESS)
	tween.tween_interval(1.0)
	tween.tween_property(menu, ^'position:x', 2000, 0.3).from_current()
	await tween.finished

	button.text = previous_text
	button.disabled = false
	name_input.editable = true

	menu.queue_free()

func _enter_tree() -> void:
	process_mode = ProcessMode.PROCESS_MODE_INHERIT if Engine.is_editor_hint() else ProcessMode.PROCESS_MODE_ALWAYS

func _ready() -> void:
	if not name_input: name_input = %NameInput
	if not score_input: score_input = %ScoreInput
	if not menu: menu = owner
	if not button and get_parent() is BaseButton: button = get_parent()
	if not button and owner is BaseButton: button = owner
	if not button.text or button.text.is_empty(): button.text = 'Submit Score'
	if not menu: push_error('missing menu on %s' % get_path())
	if not button: push_error('missing button on %s' % get_path())
	if not name_input: push_error('missing name_input on %s' % get_path())
	if not score_input: push_error('missing score_input on %s' % get_path())
	button.pressed.connect(on_pressed)
