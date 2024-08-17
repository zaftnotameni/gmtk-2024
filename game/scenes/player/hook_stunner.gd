class_name HookStunner extends Area2D

func on_stunner_hit(stunner:Stunner):
	if not get_parent().visible: return
	stunner.stun()
	for s:PlayerControllerSnappy in PlayerControllerSnappy.all():
		if s.owner == owner: s.reset_grapple()

func on_area_entered(other:Area2D):
	if other is Stunner: on_stunner_hit(other)

func _ready() -> void:
	area_entered.connect(on_area_entered)
