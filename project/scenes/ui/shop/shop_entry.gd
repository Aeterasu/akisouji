class_name ShopEntry extends Node

@export var button : UIButton = null

@export var upgrade_item : Upgrade = null 
@export var name_label : Label = null

@export var cost_label : RichTextLabel = null
@export var regular_cost_color : Color = Color(1.0, 1.0, 1.0, 1.0)
@export var not_enough_dosh_cost_color : Color = Color(1.0, 1.0, 1.0, 1.0)

@export var sunbeams : Control = null
@export var animation_speed : float = 6.0

@export var highlight : Control = null

var state : EntryState = EntryState.NONE:
	set(value):
		if (value == state):
			return
		
		state = value

		if (state == EntryState.AVAILABLE_TO_BUY):
			cost_label.text = "[left] " + str(upgrade_item.cost) + "[img]res://assets/texture/ui/hud/texture_ui_cash_symbol_small.png[/img][/left]"

		if (state == EntryState.ONE_TIME_PURCHASE_BOUGHT):
			cost_label.text = "[left] " + tr("SHOP_BOUGHT") + "[/left]"

		if (state == EntryState.UNEQUIPPED):
			cost_label.text = "[left] " + tr("SHOP_BUTTON_EQUIP") + "[/left]"

		if (state == EntryState.EQUIPPED):
			cost_label.text = "[left] " + tr("SHOP_BUTTON_EQUIPPED") + "[/left]"

enum EntryState
{
	NONE, # unspecified - we're fucked if this comes up!
	AVAILABLE_TO_BUY, # not bought yet
	UNEQUIPPED, # bought, not equipped
	EQUIPPED, # bought, equipped
	ONE_TIME_PURCHASE_BOUGHT, # unequipable, bought
}

signal on_state_update

func _ready():
	_update_state()

	if (highlight):
		highlight.modulate = Color(0.0, 0.0, 0.0)

	button.on_selected.connect(_on_button_selected)
	button.on_deselected.connect(_on_button_deselected)

func _process(delta):
	#match (state):
		#EntryState.AVAILABLE_TO_BUY:
			#cost_label.text_key = "SHOP_BUTTON_BUY"
		#EntryState.UNEQUIPPED:
			#cost_label.text_key = "SHOP_BUTTON_EQUIP"
		#EntryState.EQUIPPED:
			#cost_label.text_key = "SHOP_BUTTON_EQUIPPED"
		#EntryState.ONE_TIME_PURCHASE_BOUGHT:
			#cost_label.text_key = "SHOP_BOUGHT"

	if (sunbeams):
		sunbeams.rotation_degrees += animation_speed * delta

	if (!upgrade_item):
		return

	#if (upgrade_item.cost <= 0):
		#cost_label.hide()

	if (upgrade_item.cost > CashManager.cash):
		cost_label.modulate = not_enough_dosh_cost_color
	else:
		cost_label.modulate = regular_cost_color

	if (name_label):
		name_label.text = tr(upgrade_item.name_key)

func _attempt_buy():
	if (state == EntryState.UNEQUIPPED):
		UpgradeManager._set_current_item(upgrade_item)
		on_state_update.emit()

		return

	if (state == EntryState.AVAILABLE_TO_BUY):
		if (upgrade_item.cost < CashManager.cash):
			UpgradeManager._grant_item(upgrade_item)
			CashManager._substract_cash(upgrade_item.cost)
			UpgradeManager._set_current_item(upgrade_item)
			on_state_update.emit()

func _update_state():
	state = EntryState.AVAILABLE_TO_BUY
	
	if (upgrade_item and UpgradeManager.inventory.has(upgrade_item)):
		if (upgrade_item.one_time_purchase):
			state = EntryState.ONE_TIME_PURCHASE_BOUGHT
		else:
			state = EntryState.UNEQUIPPED

	if (upgrade_item == UpgradeManager.current_boots):
		state = EntryState.EQUIPPED

func _on_button_selected(selected_button : UIButton):
	if (!highlight):
		return

	var tween = get_tree().create_tween()
	tween.tween_property(highlight, "modulate", Color(0.8, 0.8, 0.8), 0.2)

func _on_button_deselected(deselected_button : UIButton):
	if (!highlight):
		return

	var tween = get_tree().create_tween()
	tween.tween_property(highlight, "modulate", Color(0.0, 0.0, 0.0), 0.2)