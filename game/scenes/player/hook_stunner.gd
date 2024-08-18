class_name HookStunner extends Area2D

func on_stunner_hit(stunner:Stunner):
	if not get_parent().visible: return
	if stunner.stunned: return
	if stunner.stunned: PlayerControllerSnappy.reset_grapple_owned_by(self)
	stunner.stun()

func on_area_entered(other:Area2D):
	if other is Stunner: on_stunner_hit(other)

func _ready() -> void:
	area_entered.connect(on_area_entered)
