class_name ShopCategory extends Control

@export var entries_origin : Control = null
@export var back_button : UIButton = null

@export var button_selection_handler : ButtonSelectionHandler = null

@export var sidepanel : ShopSidepanel = null

@export var shop : Shop = null

var last_entry : bool = false

func _ready():
	_deselect()

	button_selection_handler.on_button_pressed.connect(_on_shop_entry_button_pressed)

	for button in button_selection_handler.buttons:
		for node in button.get_children():
			if (node is ShopEntry):
				node.on_state_update.connect(_on_entry_state_update)
				break

func _process(delta):
	var current_entry : ShopEntry = null

	if (button_selection_handler.current_button):
		for node in button_selection_handler.current_button.get_children():
			if (node is ShopEntry):
				current_entry = node as ShopEntry
				break
	
	if (current_entry):
		sidepanel.in_category_panel.show()
		sidepanel.icon.texture = current_entry.upgrade_item.upgrade_icon
		sidepanel.current_shop_entry_upgrade = current_entry.upgrade_item

func _on_shop_entry_button_pressed(button : UIButton):
	if (button == back_button):
		shop._on_back_button_pressed()
		return

	var entry : ShopEntry = null

	for node in button.get_children():
		if (node is ShopEntry):
			entry = node as ShopEntry
			break

	if (!entry):
		return

	entry._attempt_buy()

func _select() -> ShopCategory:
	button_selection_handler._enable_all_buttons()
	self.show()

	return self

func _deselect():
	button_selection_handler._disable_all_buttons()
	self.hide()

func _on_entry_state_update():
	for button in button_selection_handler.buttons:
		for node in button.get_children():
			if (node is ShopEntry):
				node._update_state()
				break