class_name Broom extends PlayerTool

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

func _broom() -> void:
	on_broom.emit()