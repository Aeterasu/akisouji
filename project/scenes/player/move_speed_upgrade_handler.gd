class_name MoveSpeedUpgradeHandler extends Node

@export var current_upgrade : MoveSpeedUpgrade = null
@export var velocity_component : VelocityComponent = null

func _physics_process(delta):
	velocity_component.additional_upgrade_speed_multiplier = current_upgrade.speed_multiplier