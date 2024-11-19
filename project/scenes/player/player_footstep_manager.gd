class_name FootstepManager extends Node3D

@export var player : Player = null
@export var velocity_component : VelocityComponent = null

@export var raycast : RayCast3D = null
@export var step_rate : float = 0.0

@export var concrete_footstep : SoundEffectPlayer = null
@export var grass_footstep : SoundEffectPlayer = null

var cur_step_rate : float = 0.0

var current_footstep : SoundEffectPlayer = null

signal on_footstep 

func _ready():
	current_footstep = concrete_footstep

func _physics_process(delta):
	if (player.is_on_floor()):
		cur_step_rate -= delta * velocity_component.current_velocity.length()

	if (cur_step_rate <= 0):
		raycast.force_raycast_update()
		var collider = raycast.get_collider()

		if (collider):
			if (collider.is_in_group("Material-Concrete")):
				current_footstep = concrete_footstep
			if (collider.is_in_group("Material-Grass")):
				current_footstep = grass_footstep				

		current_footstep.play()
		on_footstep.emit()
		cur_step_rate = step_rate