class_name GarbageBag extends RigidBody3D

@export var audio_foley : AudioStreamPlayer3D = null

@export var audio_cooldown : float = 0.1
@export var cleaning_cooldown : float = 0.1
@export var cleaning_radius : float = 0.8

@export var raycast : RayCast3D = null

var audio_ticks : float = 0.0
var cleaning_ticks : float = 0.0
var delay : float = 0.5

var default_position : Vector3 = Vector3.ZERO

#leaf_cleaning_handler.RequestCleaningAtPosition(Vector2(global_position.x, global_position.z), Vector2(cos(rotation.y), sin(rotation.y)), Vector2.ONE * jump_cleaning_radius * multiplier * move_speed_upgrade_handler.current_upgrade.jump_cleaning_range_multiplier)

func _ready():
	body_entered.connect(_on_contact)
	cleaning_ticks = cleaning_cooldown * 0.9

	await get_tree().create_timer(0.2).timeout
	set_deferred("default_position", global_position)

func _physics_process(delta):
	audio_ticks += delta
	cleaning_ticks += delta
	delay = max(delay - delta, 0.0)

	if (raycast.is_colliding() and Vector2(linear_velocity.x, linear_velocity.z).length() >= 0.7):
		if (delay <= 0.0 and cleaning_ticks > cleaning_cooldown):
			Game.game_instance.last_cleaning_position = global_position
			Game.game_instance.last_cleaning_radius = cleaning_radius
			Game.game_instance.cleaning_handler.RequestCleaningAtPosition(Vector2(global_position.x, global_position.z), Vector2(cos(rotation.y), sin(rotation.y)), Vector2.ONE * cleaning_radius * clampf(linear_velocity.length() * 0.1, 1.0, 999.0))
			cleaning_ticks = 0.0

	if (global_position.y <= -1.0):
		global_position = default_position

func _on_contact(body : Node3D):
	set_collision_mask_value(2, true)

	if (body is GarbageBag):
		(body as GarbageBag).apply_central_impulse(Vector3(linear_velocity.x, abs(linear_velocity.y), linear_velocity.z) * 50.0)

	if (audio_ticks > audio_cooldown):
		audio_foley.pitch_scale = randf_range(0.7, 1.1)
		audio_foley.play()
		audio_ticks = 0.0