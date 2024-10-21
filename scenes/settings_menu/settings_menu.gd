class_name SettingsMenu extends Control

#@export var background : Control = null
@export var scrolling_background : Control = null

@export var on_back_pressed_type : OnBackPressedType = OnBackPressedType.GO_TO_TITLE

@export var button_selection_handler : ButtonSelectionHandler = null

@export var back_button : PaperButton = null

enum OnBackPressedType
{
	GO_TO_TITLE,
	QUEUE_FREE,
}

signal on_settings_menu_freed

func _ready():
	button_selection_handler.on_button_pressed.connect(_on_button_pressed)

func _process(delta):
	if (Input.is_action_just_pressed("pause")):
		_on_back_pressed()

func _on_button_pressed(button : PaperButton):
	for node in button_selection_handler.buttons:
		node._disable()

	match (button):
		back_button:
			_on_back_pressed()
			return

func _on_back_pressed() -> void:
	match on_back_pressed_type:
		OnBackPressedType.GO_TO_TITLE:
			transition(func(): SceneTransitionHandler.instance._load_scene("res://scenes/title_screen/title_screen.tscn"))
		OnBackPressedType.QUEUE_FREE:
			on_settings_menu_freed.emit()
			self.queue_free()

func transition(callable: Callable):
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(0.0, 0.0, 0.0), 0.2)
	tween.tween_callback(callable).set_delay(0.2)