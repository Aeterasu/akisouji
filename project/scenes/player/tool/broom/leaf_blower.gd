class_name LeafBlower extends Broom

@export var supercharge_data : BroomData = null
@export var charge_duration : float = 2.0
@export var decay_multiplier : float = 2.0
@export var shake_strength : float = 0.05

@export var block_charge : bool = false

@export var loop_audio : AudioStreamPlayer = null
@export var loop_base_volume : float = 1.0

var current_charge : float = 0.0

var wish_charge : bool = false

func _ready() -> void:
	super()
	loop_audio.play()
	loop_audio.volume_db = linear_to_db(0.0)

func _physics_process(delta) -> void:
	sin_timer += delta * walk_cycle_speed * walk_multiplier
	position = Vector3(walk_cycle_direction.x * sin(sin_timer), walk_cycle_direction.y * sin(sin_timer * 2), walk_cycle_direction.z * sin(sin_timer)) * walk_multiplier

	#if (!block_charge):
		#if (wish_charge):
			#current_charge = min(current_charge + delta, charge_duration)
		#else:
			#current_charge = max(current_charge - delta * decay_multiplier, 0.0)
	#else:
		#current_charge = max(current_charge - delta * decay_multiplier, 0.0)

	#var fract = current_charge / charge_duration
	#position += Vector3(randf_range(-fract, fract), randf_range(-fract, fract), randf_range(-fract, fract)) * shake_strength
	#position += Vector3(-0.5 * fract, 0.5 * fract, fract) * 0.025

	#if (current_charge >= charge_duration):
		#_release_charge()

	wish_brooming = in_use

	if (wish_brooming):
		current_charge = min(current_charge + delta, charge_duration)
	else:
		current_charge = max(current_charge - delta * decay_multiplier, 0.0)

	var fract = current_charge / charge_duration

	position += Vector3(randf_range(-fract, fract), randf_range(-fract, fract), randf_range(-fract, fract)) * shake_strength

	loop_audio.volume_db = linear_to_db(fract * loop_base_volume)

func _release_charge():
	current_charge = 0.0
	state_machine.start("supercharge_release")