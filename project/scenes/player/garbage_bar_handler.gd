class_name GarbageBagHandler extends Node

@export var enable_filling : bool = false
@export_range(1, 100000) var capacity : int = 2500
@export var garbage_bag_scene : PackedScene = null
@export var throw_strength : float = 8.0

var is_holding_a_bag : bool = false:
	set(value):
		is_holding_a_bag = value
		on_bag_update.emit()

var current_fill : int = 0

signal on_bag_update

func _add(amount : int):
	if (!enable_filling):
		return

	if (current_fill >= capacity):
		return

	current_fill += amount

func _is_full() -> bool:
	return current_fill >= capacity

func _discard_bag(player : Player) -> void:
	var jump_multiplier : float = 1.0
	var sprint_multiplier : float = 1.0

	if (!player.is_on_floor()):
		jump_multiplier = 1.8

	if (player.wish_sprint):
		sprint_multiplier = 1.4

	var bag = garbage_bag_scene.instantiate() as GarbageBag
	Game.game_instance.level.add_child(bag)
	bag.global_position = player.camera_origin.global_position + Vector3.DOWN * 0.3
	bag.apply_central_impulse(-player.camera.global_transform.basis.z * throw_strength * player.velocity_component.speed_multiplier * jump_multiplier * sprint_multiplier)
	bag.delay = 0.0
	bag.cleaning_ticks = 999.0
	bag.cleaning_radius *= player.velocity_component.speed_multiplier