extends Control

@export var cash_label : Label = null
@export var animation_duration : float = 0.3

@export var cash_reward_label : Label = null

var current_cash : float = 0

func _ready():
	CashManager.on_cash_rewarded.connect(_on_cash_rewarded)

func _process(delta : float):
	cash_label.text = CashManager.format_currency(current_cash)

func _on_cash_rewarded(amount : float):
	var new_label : Label = cash_reward_label.duplicate()
	add_child(new_label)
	new_label.text = "+" + CashManager.format_currency(amount)
	new_label.show()

	var tween : Tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(new_label, "position", new_label.position + Vector2.LEFT * (len(CashManager.format_currency(CashManager.cash)) - 1) * cash_label.get("theme_override_font_sizes/font_size") + Vector2.LEFT * 16, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(new_label, "modulate", Color(new_label.modulate.r, new_label.modulate.g, new_label.modulate.b, 0.0), 0.2).set_delay(0.6)
	tween.tween_callback(new_label.queue_free).set_delay(1.5)

	tween.tween_property(self, "current_cash", CashManager.cash, animation_duration)