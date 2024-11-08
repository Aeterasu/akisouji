class_name RankingManager extends Node

var time_elapsed  : float = 0.0

var level : Level = null

enum Rank
{
	D,
	C,
	B,
	A,
	S,
}

func _ready() -> void:
	pass

func _physics_process(delta) -> void:
	time_elapsed  += delta

func get_current_rank() -> Rank:
	if (!is_instance_valid(level)):
		return Rank.D

	if (time_elapsed <= level.s_rank_target_time):
		return Rank.S
	elif (time_elapsed <= level.a_rank_target_time):
		return Rank.A
	elif (time_elapsed <= level.b_rank_target_time):
		return Rank.B
	elif (time_elapsed <= level.c_rank_target_time):
		return Rank.C
	elif (time_elapsed <= level.d_rank_target_time):
		return Rank.D

	return Rank.D

func get_formatted_time_elapsed() -> String:
	var minutes = time_elapsed / 60
	var seconds = fmod(time_elapsed, 60)

	return "%02d:%02d" % [minutes, seconds]