extends Node

@export var level_grades : Array[RankingManager.Rank] = []

@export var level_highscores : Array[int] = []

var current_level_id : int = 0

func _ready():
	level_highscores.resize(len(level_grades))

func _update_current_level_grade(grade : RankingManager.Rank, score : int):
	if (grade > level_grades[current_level_id]):
		level_grades[current_level_id] = grade

	if (score > level_highscores[current_level_id]):
		level_highscores[current_level_id] = score