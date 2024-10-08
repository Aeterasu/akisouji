extends Control

@export var cash_label : Label = null

func _process(delta):
	cash_label.text = str(CashManager.cash) + "$"