class_name WeakPoint extends Area2D

signal sig_weakpoint_hit()

@export_group('internals')
@export var sprite : AnimatedSprite2D
@export var health : int = 3
@export var animation_stages : Array[String] = ['dead', 'last_health', 'half_health', 'full_health']

const GROUP := 'weak_point'

func change_health_to(new_health_value:int=health):
	if new_health_value > (animation_stages.size() - 1):
		push_error('invalid health value: %s, current: %s at %s' % [new_health_value, health, get_path()])
		return
	health = new_health_value
	sprite.play(animation_stages[max(health, 0)])

func on_hook_stunner_hit_weakpoint(hook_pointy_bit:HookStunner):
	sig_weakpoint_hit.emit()
	print_verbose('weakpoint hit! %s => %s' % [health, health - 1])
	PlayerControllerSnappy.reset_grapple_owned_by(hook_pointy_bit)
	change_health_to(health - 1)

func on_area_entered(other:Area2D):
	if other is HookStunner: on_hook_stunner_hit_weakpoint(other)

func _enter_tree() -> void:
	add_to_group(GROUP)

func _ready() -> void:
	area_entered.connect(on_area_entered)
	if not sprite: sprite = %Heart
	change_health_to(health)

static func tree() -> SceneTree: return Engine.get_main_loop()
static func all() -> Array: return tree().get_nodes_in_group(GROUP)
static func first() -> Player: return tree().get_first_node_in_group(GROUP)
