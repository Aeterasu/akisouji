class_name RankingManager extends Node

@export var cash_bonus_s_rank : float = 1000.0
@export var cash_bonus_a_rank : float = 750.0
@export var cash_bonus_b_rank : float = 350.0
@export var cash_bonus_c_rank : float = 100.0
@export var cash_bonus_d_rank : float = 50.0

@export var multiplier_brooming : float = 1.0
@export var multiplier_sprinting : float = 1.1
@export var multiplier_jumping : float = 1.1
@export var multiplier_sprint_jumping : float = 1.25
@export var multiplier_garbage_bag : float = 1.5

@export var multiplier_speed_clear_s : float = 3.0
@export var multiplier_speed_clear_a : float = 2.0
@export var multiplier_speed_clear_b : float = 1.25

var time_elapsed  : float = 0.0

var score : float = 0:
	set(value):
		if (value < 0):
			value = 0

		score = value

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

enum ScoreRewardType
{
	BROOMING = 0,
	SPRINTING = 1,
	JUMPING = 2,
	SPRINT_JUMPING = 3,
	GARBAGE_BAG = 4,
}

func _physics_process(delta) -> void:
	if (completed):
		return

	time_elapsed  += delta

func _get_multiplier_from_reward_type(type : ScoreRewardType) -> float:
	match type:
		ScoreRewardType.BROOMING:
			return multiplier_brooming
		ScoreRewardType.SPRINTING:
			return multiplier_sprinting
		ScoreRewardType.JUMPING:
			return multiplier_jumping
		ScoreRewardType.SPRINT_JUMPING:
			return multiplier_sprint_jumping
		ScoreRewardType.GARBAGE_BAG:
			return multiplier_garbage_bag

	return 1.0

func get_current_rank() -> Rank:
	if (!is_instance_valid(level)):
		return Rank.D

	if (score >= level.s_rank_target_score):
		return Rank.S
	elif (score >= level.a_rank_target_score):
		return Rank.A
	elif (score >= level.b_rank_target_score):
		return Rank.B
	elif (score >= level.c_rank_target_score):
		return Rank.C
		
	return Rank.D

func get_current_time_multiplier() -> float:
	if (!is_instance_valid(level)):
		return 1.0

	if (time_elapsed <= level.s_target_speed_clear):
		return multiplier_speed_clear_s
	elif (time_elapsed <= level.a_target_speed_clear):
		return multiplier_speed_clear_a
	elif (time_elapsed <= level.b_target_speed_clear):
		return multiplier_speed_clear_b

	return 1.0

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

func _on_leaves_cleaned(amount : int):
	score += float(amount) * 2.0 * _get_multiplier_from_reward_type(Game.game_instance.last_cleaning_type)

func _get_current_score() -> int:
	return floor(score)