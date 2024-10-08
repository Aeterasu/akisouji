extends Node

@export var base_cash_reward : float = 0.1
@export var buffer_clean_time : float = 2.0

var cash : int = 0

var cash_buffer : float = 0
var timer : Timer = Timer.new()

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
	cash += round(cash_buffer)
	cash_buffer = 0