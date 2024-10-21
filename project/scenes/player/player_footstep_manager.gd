extends Node3D

@export var player : Player = null
@export var velocity_component : VelocityComponent = null

@export var step_rate : float = 0.0

@export var concrete_footstep : SoundEffectPlayer = null
@export var grass_footstep : SoundEffectPlayer = null

var cur_step_rate : float = 0.0

var current_footstep : SoundEffectPlayer = null

func _ready():
	current_footstep = concrete_footstep

func _physics_process(delta):
	if (player.is_on_floor()):
		cur_step_rate -= delta * velocity_component.current_velocity.length()

	if (cur_step_rate <= 0):
		var collider = _get_raycast_collider()

		if (collider):
			if (collider.is_in_group("Material-Concrete")):
				current_footstep = concrete_footstep
			if (collider.is_in_group("Material-Grass")):
				current_footstep = grass_footstep				

		current_footstep.play()
		cur_step_rate = step_rate

func _get_raycast_collider():
	var space_state = get_world_3d().direct_space_state

	var origin = global_position + Vector3.UP
	var end = origin + 4 * Vector3.DOWN
	var query = PhysicsRayQueryParameters3D.create(origin, end, 4294967295, [player.get_rid()])

	var result = space_state.intersect_ray(query)

	if (result):
		return result["collider"]
	