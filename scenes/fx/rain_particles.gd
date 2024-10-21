extends GPUParticles3D

@export var rain_owner : Node3D = null;

var default_global_position : Vector3 = Vector3()

func _ready():
	default_global_position = global_position

func _physics_process(delta):
	if (get_tree().paused and interpolate):
		speed_scale = 0.0
		interpolate = false
		return

	if (!get_tree().paused and !interpolate):
		speed_scale = 1.0
		interpolate = true

	if (rain_owner):
		global_position = Vector3(rain_owner.global_position.x, default_global_position.y, rain_owner.global_position.z)