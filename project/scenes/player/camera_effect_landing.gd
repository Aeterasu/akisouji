class_name CameraEffectLanding extends Node3D

@export var direction = Vector3(0.0, -0.1, 0.0)
@export var in_duration = 0.2
@export var out_duration = 0.6

func _animate():
	create_tween().tween_property(self, "position", direction, in_duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	create_tween().tween_property(self, "position", Vector3.ZERO, out_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_delay(in_duration)