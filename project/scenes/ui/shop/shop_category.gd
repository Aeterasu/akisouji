class_name ShopCategory extends Control

@export var entries_origin : Control = null

@export var button_selection_handler : ButtonSelectionHandler = null

func _ready():
	_deselect()

	button_selection_handler.on_button_pressed.connect(_on_shop_entry_button_pressed)

	for entry in entries_origin.get_children():
		if (entry is ShopEntry):
			entry.on_state_update.connect(_on_entry_state_update)

func _on_shop_entry_button_pressed(button : UIButton):
	var parent = button.get_parent()

	if (parent is not ShopEntry):
		return

	var entry = parent as ShopEntry
	entry._attempt_buy()

func _select() -> ShopCategory:
	button_selection_handler._enable_all_buttons()
	self.show()

	return self

func _deselect():
	button_selection_handler._disable_all_buttons()
	self.hide()

func _on_entry_state_update():
	for entry in entries_origin.get_children():
		if (entry is ShopEntry):
			entry._update_state()