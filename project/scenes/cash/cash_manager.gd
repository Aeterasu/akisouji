extends Node

@export var base_cash_reward : float = 0.1
@export var buffer_clean_time : float = 2.0

var cash : float = 0

var cash_buffer : float = 0
var timer : Timer = Timer.new()

signal on_cash_rewarded

func _ready() -> void:
	add_child(timer)
	timer.wait_time = buffer_clean_time
	timer.one_shot = true
	timer.timeout.connect(_on_buffer_timeout)

func _physics_process(delta) -> void:
	pass

func _grant_cash(amount : float = base_cash_reward) -> void:
	if (amount <= 0.0):
		return

	cash_buffer += amount
	
	if (timer.is_stopped()):
		timer.start()

func _on_buffer_timeout():
	var amount : float = cash_buffer
	cash += amount
	cash_buffer = 0

	on_cash_rewarded.emit(amount)

func _reward_leaf_cleaning(leaf_amount : float):
	_grant_cash(leaf_amount * base_cash_reward)

func format_currency(number : float) -> String:
	
	# Place the decimal separator
	var txt_numb = "%.2f" % number
	
	# Place the thousands separator
	for idx in range(txt_numb.find(".") - 3, 0, -3):
		txt_numb = txt_numb.insert(idx, ",")
	return(txt_numb)