extends Control

@export var cash_label : Label = null
@export var animation_duration : float = 0.3

@export var cash_reward_label : Label = null

@export var target_cash_label : Label = null
@export var target_appended_cash_label : Label = null

var current_cash : float = 0

func _ready():
	current_cash = CashManager.cash

	CashManager.on_cash_rewarded.connect(_on_cash_rewarded)
	CashManager.on_cash_substracted.connect(_on_cash_substracted)

func _process(delta : float):
	cash_label.text = CashManager.format_currency(current_cash)

func _on_cash_rewarded(amount : float):
	var new_label : Label = cash_reward_label.duplicate()
	new_label.text = "+" + CashManager.format_currency(amount)
	target_cash_label.text = CashManager.format_currency(CashManager.cash)
	add_child(new_label)

	call_deferred("_tween_new_cash_label", new_label)

func _tween_new_cash_label(label : Label):
	label.show()

	var target_position : Vector2 = label.position + Vector2.LEFT * label.size.x + Vector2.LEFT * 8

	var tween : Tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position", target_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(label, "modulate", Color(label.modulate.r, label.modulate.g, label.modulate.b, 0.0), 0.2).set_delay(CashManager.animation_delay)
	tween.tween_callback(label.queue_free).set_delay(1.0 + CashManager.animation_delay)

	tween.tween_property(self, "current_cash", CashManager.cash, animation_duration)

func _on_cash_substracted(amount : float):
	var tween : Tween = get_tree().create_tween()
	tween.set_parallel(true)

	tween.tween_property(self, "current_cash", CashManager.cash, animation_duration)