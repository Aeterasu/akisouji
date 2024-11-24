class_name Broom extends PlayerTool

@export var data : BroomData = null

@export var sweep_audio : SoundEffectPlayer = null

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

signal on_sweep_fx

func _physics_process(delta):
	super(delta)
	wish_brooming = in_use

func _broom() -> void:
	on_broom.emit()

func _make_sweep_fx() -> void:
	on_sweep_fx.emit(self)