extends Node

@export_range(0.0, 999999.0) var cash : float = 0

@export var base_cash_reward : float = 0.1
@export var buffer_clean_time : float = 2.0

@export var golden_broom_max_cap : float = 10000.0
@export var golden_broom_base_multiplier : float = 12.0
@export var golden_broom_consumption : float = 0.045

@export var reward_ding : AudioStreamPlayer = null

var cash_buffer : float = 0
var timer : Timer = Timer.new()

var animation_delay : float = 0.0

var is_buffer_paused : bool = false

var finalize : bool = false

signal on_cash_rewarded
signal on_cash_substracted

func _ready() -> void:
	add_child(timer)
	timer.wait_time = buffer_clean_time
	timer.one_shot = true
	timer.timeout.connect(_clean_buffer)

func _physics_process(delta) -> void:
	timer.paused = is_buffer_paused

func _grant_cash(amount : float = base_cash_reward, new_anim_duration : float = 0.6) -> void:
	if (amount <= 0.0):
		return

	cash_buffer += amount
	
	if (timer.is_stopped()):
		timer.start()

	animation_delay = new_anim_duration

	if (is_instance_valid(Game.game_instance)):
		Game.game_instance.cash_earned += amount

func _substract_cash(amount : float):
	if (amount <= 0):
		return

	cash = max(cash - amount, 0.0)

	on_cash_substracted.emit(amount)

func _clean_buffer():
	var amount : float = cash_buffer
	cash += amount
	cash_buffer = 0

	on_cash_rewarded.emit(amount)

	is_buffer_paused = false

	if (amount > 0.0):
		reward_ding.pitch_scale = randf_range(0.8, 1.1)
		reward_ding.play()

	if (UpgradeManager):
		UpgradeManager._check_unlocks()

	SaveManager._save()

func _reward_leaf_cleaning(leaf_amount : float):
	var anim = 0.6

	if (finalize):
		anim = animation_delay

	_grant_cash(leaf_amount * base_cash_reward, anim)

func format_currency(number : float) -> String:
	
	# Place the decimal separator
	var txt_numb = "%.2f" % number
	
	# Place the thousands separator
	for idx in range(txt_numb.find(".") - 3, 0, -3):
		txt_numb = txt_numb.insert(idx, ",")
	return(txt_numb)

func _pause_buffer() -> void:
	is_buffer_paused = true

func _get_golden_broom_multiplier() -> float:
	return max((min(cash, golden_broom_max_cap) / golden_broom_max_cap) * golden_broom_base_multiplier, 1.0)