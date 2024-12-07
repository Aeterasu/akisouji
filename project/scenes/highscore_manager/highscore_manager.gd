extends Node

@export var level_grades : Array[RankingManager.Rank] = []

var current_level_id : int = 0

func _ready():
	pass

func _update_current_level_grade(grade : RankingManager.Rank):
	if (grade > level_grades[current_level_id]):
		level_grades[current_level_id] = grade
