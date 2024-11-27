class_name GarbageBag extends RigidBody3D

@export var audio_foley : AudioStreamPlayer3D = null

func _ready():
	body_entered.connect(_on_contact)

func _on_contact(body : Node3D):
	set_collision_mask_value(2, true)
	audio_foley.pitch_scale = randf_range(0.7, 1.1)
	audio_foley.play()