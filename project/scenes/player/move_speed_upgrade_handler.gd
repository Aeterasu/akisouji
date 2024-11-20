class_name MoveSpeedUpgradeHandler extends Node

@export var player : Player = null

@export var current_upgrade : MoveSpeedUpgrade = null
@export var velocity_component : VelocityComponent = null

func _physics_process(delta):
	if (!player.wish_sprint):
		velocity_component.additional_upgrade_speed_multiplier = current_upgrade.speed_multiplier
	else:
		velocity_component.additional_upgrade_speed_multiplier = current_upgrade.sprint_multiplier