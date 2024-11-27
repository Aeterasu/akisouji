class_name GarbageBag extends RigidBody3D

@export var audio_foley : AudioStreamPlayer3D = null

@export var audio_cooldown : float = 0.1
@export var cleaning_cooldown : float = 0.1
@export var cleaning_radius : float = 0.8

@export var raycast : RayCast3D = null

var audio_ticks : float = 0.0
var cleaning_ticks : float = 0.0
var delay : float = 0.5

#leaf_cleaning_handler.RequestCleaningAtPosition(Vector2(global_position.x, global_position.z), Vector2(cos(rotation.y), sin(rotation.y)), Vector2.ONE * jump_cleaning_radius * multiplier * move_speed_upgrade_handler.current_upgrade.jump_cleaning_range_multiplier)

func _ready():
	body_entered.connect(_on_contact)
	cleaning_ticks = cleaning_cooldown * 0.9

func _process(delta):
	audio_ticks += delta
	cleaning_ticks += delta
	delay = max(delay - delta, 0.0)

	if (raycast.is_colliding() and Vector2(linear_velocity.x, linear_velocity.z).length() >= 0.5):
		if (delay <= 0.0 and cleaning_ticks > cleaning_cooldown):
			Game.game_instance.last_cleaning_position = global_position
			Game.game_instance.last_cleaning_radius = cleaning_radius
			Game.game_instance.cleaning_handler.RequestCleaningAtPosition(Vector2(global_position.x, global_position.z), Vector2(cos(rotation.y), sin(rotation.y)), Vector2.ONE * cleaning_radius)
			cleaning_ticks = 0.0

func _on_contact(body : Node3D):
	set_collision_mask_value(2, true)

	if (audio_ticks > audio_cooldown):
		audio_foley.pitch_scale = randf_range(0.7, 1.1)
		audio_foley.play()
		audio_ticks = 0.0