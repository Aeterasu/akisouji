class_name PlayerTool extends Node3D

@export var use_type : UseType = UseType.CLICK

@export var auto_use : bool = false

@export var animation_tree : AnimationTree = null
var state_machine : AnimationNodeStateMachinePlayback = null

@export var walk_cycle_speed : float = 5.0
@export var walk_cycle_direction : Vector3 = Vector3()

@export var hud_icon : Texture2D = null
@export var tool_inventory_id : int = 0

var walk_multiplier : float = 1.0
var sin_timer : float = 0.0

var is_equipped : bool = false
var wish_sprint : bool = false

var in_use : bool = false
var in_use_secondary : bool = false

var allow_switch : bool = true

enum UseType
{
	CLICK,
	HOLD,
}

func _ready():
	if (animation_tree):
		state_machine = animation_tree.get("parameters/playback")
		state_machine.start("equip")

func _physics_process(delta):
	sin_timer += delta * walk_cycle_speed * walk_multiplier
	position = Vector3(walk_cycle_direction.x * sin(sin_timer), walk_cycle_direction.y * sin(sin_timer * 2), walk_cycle_direction.z * sin(sin_timer)) * walk_multiplier

func _set_sprint_toggle(toggle : bool) -> void:
	if (wish_sprint == toggle):
		return

	wish_sprint = toggle

func _unequip() -> void:
	is_equipped = false
	in_use = false

func _equip() -> void:
	is_equipped = true

func _use_primary() -> void:
	pass

func _use_secondary() -> void:
	pass