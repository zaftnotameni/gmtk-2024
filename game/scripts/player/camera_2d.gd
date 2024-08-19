extends Camera2D

@onready var min_x : float = 1000000
@onready var min_y : float = 1000000
@onready var max_x : float = -1000000
@onready var max_y : float = -1000000

func _ready() -> void:
	await get_tree().create_timer(0.2).timeout
	var layers := get_tree().get_nodes_in_group('tiles')
	for layer:TileMapLayer in layers:
		if (layer.name as String).contains('ack'): continue
		for cell in layer.get_used_cells():
			var glopos := layer.to_global(layer.map_to_local(cell))
			min_x = min(min_x, glopos.x)
			min_y = min(min_y, glopos.y)
			max_x = max(max_x, glopos.x)
			max_y = max(max_y, glopos.y)
		limit_left = roundi(min_x - 16 * 1)
		limit_right = roundi(max_x + 16 * 1)
		limit_top = roundi(min_y - 128)
		limit_bottom = roundi(max_y + 96)
