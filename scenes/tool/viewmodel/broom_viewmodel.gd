class_name BroomViewmodel extends Node3D

@export var animation_tree : AnimationTree = null
var state_machine : AnimationNodeStateMachinePlayback = null

@export var walk_cycle_speed : float = 5.0
@export var walk_cycle_direction : Vector3 = Vector3()

var walk_multiplier : float = 1.0
var sin_timer : float = 0.0

var brooming_state : BroomingState = BroomingState.NONE

var wish_brooming : bool = false
var wish_sprint : bool = false

enum BroomingState
{
	NONE,
	BROOMING_START,
	BROOMING_LOOP,
	BROOMING_END,
}

signal on_broom

func _ready():
	state_machine = animation_tree.get("parameters/playback")
	
	state_machine.start("idle")

func _physics_process(delta):
	sin_timer += delta * walk_cycle_speed * walk_multiplier
	position = Vector3(walk_cycle_direction.x * sin(sin_timer), walk_cycle_direction.y * sin(sin_timer * 2), walk_cycle_direction.z * sin(sin_timer)) * walk_multiplier

func _set_sprint_toggle(toggle : bool) -> void:
	if (wish_sprint == toggle):
		return

	wish_sprint = toggle

	#animation_tree["parameters/conditions/wish_sprint"] = toggle

func _broom() -> void:
	on_broom.emit()