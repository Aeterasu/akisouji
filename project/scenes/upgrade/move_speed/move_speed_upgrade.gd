class_name MoveSpeedUpgrade extends Upgrade

@export_range(0.0, 3.0) var speed_multiplier : float = 1.0
@export_range(0.0, 3.0) var sprint_multiplier : float = 1.0

@export var allow_walk_cleaning : bool = false
@export_range(0.0, 3.0) var walk_cleaning_range_multiplier : float = 1.0
@export_range(0.0, 3.0) var sprint_cleaning_range_multiplier : float = 1.0
@export_range(0.0, 3.0) var jump_cleaning_range_multiplier : float = 1.0