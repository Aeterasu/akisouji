class_name RankingManager extends Node

@export var cash_bonus_s_rank : float = 1000.0
@export var cash_bonus_a_rank : float = 750.0
@export var cash_bonus_b_rank : float = 350.0
@export var cash_bonus_c_rank : float = 100.0
@export var cash_bonus_d_rank : float = 50.0

var time_elapsed  : float = 0.0

var level : Level = null

var completed : bool

enum Rank
{
	NONE = -1,
	D = 0,
	C = 1,
	B = 2,
	A = 3,
	S = 4,
}

func _ready() -> void:
	pass

func _physics_process(delta) -> void:
	if (completed):
		return

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

func _get_current_cash_bonus() -> float:
	var rank : Rank = get_current_rank()

	match rank:
		Rank.D:
			return cash_bonus_d_rank
		Rank.C:
			return cash_bonus_c_rank
		Rank.B:
			return cash_bonus_b_rank
		Rank.A:
			return cash_bonus_a_rank
		Rank.S:
			return cash_bonus_s_rank

	return 0.0