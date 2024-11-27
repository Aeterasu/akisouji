class_name GarbageBagHandler extends Node

@export_range(1, 100000) var capacity : int = 2500
@export var garbage_bag_scene : PackedScene = null
@export var throw_strength : float = 8.0

var is_holding_a_bag : bool = false

var current_fill : int = 0

func _process(delta) -> void:
    pass

func _add(amount : int):
    if (current_fill >= capacity):
        return

    current_fill += amount

func _is_full() -> bool:
    return current_fill >= capacity

func _discard_bag(player : Player) -> void:
    var bag = garbage_bag_scene.instantiate() as RigidBody3D
    Game.game_instance.level.add_child(bag)
    bag.global_position = player.camera_origin.global_position + Vector3.DOWN * 0.3
    bag.apply_central_impulse(-player.camera.global_transform.basis.z * throw_strength)