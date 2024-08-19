### keeps track of the current state of the game
class_name GameManagerState extends Node

signal sig_game_state_changed(new_state:GameState, prev_state:GameState)
signal sig_game_state_game()
signal sig_transition_finished()
signal sig_transition_started()

enum GameState { INITIAL = 0, LOADING, TITLE, MENU, CUTSCENE, GAME, PAUSED, VICTORY, DEFEAT }

static var current_time : float = 0.0
static var victory_time : float = 0.0
static var game_state : GameState = GameState.INITIAL
static var game_state_stack : Array[GameState] = [GameState.INITIAL]
static var transition : bool = false

func transition_start():
	print_verbose('started transition')
	transition = true
	sig_transition_started.emit()

func transition_finish():
	print_verbose('finished transition')
	transition = false
	sig_transition_finished.emit()

# these functions completely override the state stack, setting it to a single state
func mark_as_initial(): mark_as(GameState.INITIAL)
func mark_as_loading(): mark_as(GameState.LOADING)
func mark_as_title(): mark_as(GameState.TITLE)
func mark_as_game(): mark_as(GameState.GAME)
func mark_as_paused(): mark_as(GameState.PAUSED)
func mark_as_custscene(): mark_as(GameState.CUTSCENE)
func mark_as_victory(): mark_as(GameState.VICTORY)
func mark_as_defeat(): mark_as(GameState.DEFEAT)
func mark_as_menu(): mark_as(GameState.MENU)

# these functions push a state to the stack,
# useful for showing a pause menu or starting a cutscene and then going back to the previous state
func push_initial(): push_as(GameState.INITIAL)
func push_loading(): push_as(GameState.LOADING)
func push_title(): push_as(GameState.TITLE)
func push_game(): push_as(GameState.GAME)
func push_paused(): push_as(GameState.PAUSED)
func push_cutscene(): push_as(GameState.CUTSCENE)
func push_victory(): push_as(GameState.VICTORY)
func push_defeat(): push_as(GameState.DEFEAT)
func push_menu(): push_as(GameState.MENU)

# go back to the previous state, only works if the current state matches what the function expects
func pop_initial(): pop_as(GameState.INITIAL)
func pop_loading(): pop_as(GameState.LOADING)
func pop_title(): pop_as(GameState.TITLE)
func pop_game(): pop_as(GameState.GAME)
func pop_paused(): pop_as(GameState.PAUSED)
func pop_cutscene(): pop_as(GameState.CUTSCENE)
func pop_victory(): pop_as(GameState.VICTORY)
func pop_defeat(): pop_as(GameState.DEFEAT)
func pop_menu(): pop_as(GameState.MENU)

func pop_as(expected_current_state:GameState):
	if expected_current_state != game_state: return
	game_state_stack.pop_back()
	if game_state_stack.is_empty(): game_state_stack.push_back(GameState.INITIAL)
	game_state = game_state_stack[-1]
	print_verbose('game_state: %s' % str(game_state_stack.map(name_of)))
	sig_game_state_changed.emit(game_state)
	if game_state == GameState.GAME: sig_game_state_game.emit()

func push_as(new_state:GameState):
	if new_state == game_state: return
	game_state = new_state
	game_state_stack.push_back(new_state)
	print_verbose('game_state: %s' % str(game_state_stack.map(name_of)))
	sig_game_state_changed.emit(game_state)
	if game_state == GameState.GAME: sig_game_state_game.emit()
	if game_state == GameState.TITLE: victory_time = 0
	if game_state == GameState.VICTORY: victory_time = current_time

func mark_as(new_state:GameState):
	if new_state == game_state: return
	var prev_state := game_state
	game_state = new_state
	game_state_stack = [new_state]
	print_verbose('game_state: %s' % str(game_state_stack.map(name_of)))
	sig_game_state_changed.emit(game_state, prev_state)
	if game_state == GameState.GAME: sig_game_state_game.emit()
	if game_state == GameState.TITLE: victory_time = 0
	if game_state == GameState.VICTORY: victory_time = current_time

func name_of(state_id:GameState) -> String:
	return GameState.find_key(state_id)

func _enter_tree() -> void:
	process_mode = ProcessMode.PROCESS_MODE_INHERIT if Engine.is_editor_hint() else ProcessMode.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if game_state == GameState.GAME: current_time += delta

static func reset_time():
	current_time = 0.0
