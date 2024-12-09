class_name FootstepManager extends Node3D

@export var player : Player = null
@export var velocity_component : VelocityComponent = null

@export var raycast : RayCast3D = null
@export var step_rate : float = 0.0

@export var concrete_footstep : SoundEffectPlayer = null
@export var grass_footstep : SoundEffectPlayer = null

@export var leaf_footstep : SoundEffectPlayer = null

@export var water_footstep : AudioStreamPlayer = null

var cur_step_rate : float = 0.0

var current_footstep : SoundEffectPlayer = null

var is_in_water : bool = false

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

		if (Game.game_instance.cleaning_handler and Game.game_instance.cleaning_handler.AreThereLeavesInRadius(Vector2(global_position.x, global_position.z), 0.5)):
			#leaf_footstep.pitch_scale = randf_range(0.8, 1.0)
			leaf_footstep.play()

		if (is_in_water):
			water_footstep.play()