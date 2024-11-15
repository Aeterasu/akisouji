class_name Broom extends PlayerTool

@export var data : BroomData = null

var brooming_state : BroomingState = BroomingState.NONE

var wish_brooming : bool = false

enum BroomingState
{
	NONE,
	BROOMING_START,
	BROOMING_LOOP,
	BROOMING_END,
}

signal on_broom

func _physics_process(delta):
	super(delta)
	wish_brooming = in_use

func _broom() -> void:
	on_broom.emit()