class_name GarbageBag extends RigidBody3D

@export var audio_foley : AudioStreamPlayer3D = null

@export var audio_cooldown : float = 0.1

var ticks : float = 0.0

func _ready():
	body_entered.connect(_on_contact)

func _process(delta):
	ticks += delta

func _on_contact(body : Node3D):
	set_collision_mask_value(2, true)

	if (ticks > audio_cooldown):
		audio_foley.pitch_scale = randf_range(0.7, 1.1)
		audio_foley.play()
		ticks = 0.0