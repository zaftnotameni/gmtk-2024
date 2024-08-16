class_name GameManagerLayers extends Node2D

@onready var game : CanvasLayer = layer_game()
@onready var background : CanvasLayer = layer_background()
@onready var hud : CanvasLayer = layer_hud()
@onready var menu : CanvasLayer = layer_menu()

static func layer_game() -> CanvasLayer: return tree().get_first_node_in_group('game_layer')
static func layer_background() -> CanvasLayer: return tree().get_first_node_in_group('background_layer')
static func layer_hud() -> CanvasLayer: return tree().get_first_node_in_group('hud_layer')
static func layer_menu() -> CanvasLayer: return tree().get_first_node_in_group('menu_layer')

static func clear_game(): clear_layer(layer_game())
static func clear_background(): clear_layer(layer_background())
static func clear_hud(): clear_layer(layer_hud())
static func clear_menu(): clear_layer(layer_menu())

static func clear_layer(layer:CanvasLayer):
	if layer and not layer.is_queued_for_deletion():
		for child in layer.get_chidren():
			if child and not child.is_queued_for_deletion():
				child.queue_free()

static func tree() -> SceneTree: return Engine.get_main_loop()

func _enter_tree() -> void:
	process_mode = ProcessMode.PROCESS_MODE_INHERIT if Engine.is_editor_hint() else ProcessMode.PROCESS_MODE_ALWAYS
