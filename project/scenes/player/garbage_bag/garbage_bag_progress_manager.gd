class_name GarbageBagProgressManager extends Node

@export var bag_reward : float = 100.0
@export var bag_score : float = 10000.0

var current_disposed : int = 0:
	set(value):
		if (value < 0):
			value = 0

		if (value > target):
			value = target

		current_disposed = value

var target : int = 0:
	set(value):
		if (value < 0):
			value = 0

		target = value

func _dispose_bag() -> void:
	current_disposed += 1

	CashManager._grant_cash(bag_reward)
	CashManager._clean_buffer()
	Game.game_instance.ranking_manager.score += bag_score