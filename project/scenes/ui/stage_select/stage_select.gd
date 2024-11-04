class_name StageSelect extends Control

@export var button_selection_handler : ButtonSelectionHandler = null
@export var back_button : UIButton = null
@export var proceed_button : UIButton = null

func _ready():
	button_selection_handler.on_button_pressed.connect(_on_button_pressed)

func _on_button_pressed(button : UIButton):
	match (button):
		back_button:
			_on_back_button_pressed()
		proceed_button:
			SceneTransitionHandler.instance._load_shop_scene()

func _on_back_button_pressed():
	SceneTransitionHandler.instance._load_previous_scene()