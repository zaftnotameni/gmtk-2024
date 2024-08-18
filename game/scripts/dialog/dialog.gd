class_name TypewritterDialog extends Label

signal sig_fully_completed()
signal sig_page_completed()

@export var typing_speed: float = 0.09
@export var type_on_ready: bool = true
@export_multiline var pages: Array[String] = []

var page : int = 0
var current_page_text : String = ""
var current_text: String = ""
var typing_index: int = 0
var is_typing: bool = false
var show_cursor: bool = true
var cursor_blink_interval: float = 0.01

func _unhandled_input(event: InputEvent) -> void:
	if PlayerInput.is_grapple(event):
		get_viewport().set_input_as_handled()
		set_process_unhandled_input(false)
		if page >= (pages.size() - 1):
			sig_fully_completed.emit()
			return
		page += 1
		type_current_page()

func on_page_completed():
	if page >= (pages.size() - 1):
		sig_fully_completed.emit()
		return

	text += '\n[space/Y/Triangle] >>'
	set_process_unhandled_input(true)

func _ready() -> void:
	sig_page_completed.connect(on_page_completed)
	if type_on_ready: start_typing()

func type_current_page():
	current_text = ""
	typing_index = 0
	is_typing = true
	show_cursor = true
	text = ""
	current_page_text = pages[page]
	start_cursor_blinking()
	continue_typing()

func start_typing(pages_of_text: Array[String] = pages) -> void:
	pages = pages_of_text
	type_current_page()

func _process(_delta: float) -> void:
	if is_typing:
		continue_typing()

func continue_typing(speed: float = 1.0) -> void:
	if typing_index < current_page_text.length():
		current_text += current_page_text[typing_index]
		text = current_text + ("|" if show_cursor else "")
		typing_index += 1
		await get_tree().create_timer(typing_speed * speed).timeout
		continue_typing(speed)
	else:
		is_typing = false
		text = current_text
		sig_page_completed.emit()

func skip_typing() -> void:
	is_typing = false
	current_text = current_page_text
	text = current_text
	sig_page_completed.emit()

func start_cursor_blinking() -> void:
	while is_typing:
		show_cursor = !show_cursor
		text = current_text + ("|" if show_cursor else "")
		await get_tree().create_timer(cursor_blink_interval).timeout

