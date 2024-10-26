extends GPUParticles2D

@export var parent_control : Control = null

var default_position : Vector2 = Vector2()

func _ready():
    default_position = position

func _process(delta):
    if (parent_control):
        #scale = parent_control.scale
        position = default_position * Vector2(parent_control.scale.x, 1.0)
        (process_material as ParticleProcessMaterial).scale_min = parent_control.scale.x
        (process_material as ParticleProcessMaterial).scale_max = parent_control.scale.x + 0.5
        lifetime = 8 * parent_control.scale.x