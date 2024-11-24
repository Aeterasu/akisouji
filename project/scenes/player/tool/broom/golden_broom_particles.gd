extends GPUParticles3D

@export var base_amount : int = 6

func _process(delta):
	amount = base_amount * int(CashManager._get_golden_broom_multiplier() * 4.0) 