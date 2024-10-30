extends Control

@export var button_selection_handler : ButtonSelectionHandler = null

@export var start_button : UIButton = null
@export var gallery_button : UIButton = null
@export var options_button : UIButton = null
@export var exit_button : UIButton = null

@export var submenu_origin : Node = null

@export var settings_scene : PackedScene = null

@export var blackout : ColorRect = null

func _ready():
	button_selection_handler.on_button_pressed.connect(_on_button_pressed)

	blackout.color = Color(0.0, 0.0, 0.0, 1.0)
	var tween = create_tween()
	tween.tween_property(blackout, "color", Color(0.0, 0.0, 0.0, 0.0), 0.3)

func _on_button_pressed(button : UIButton):
	button_selection_handler._disable_all_buttons()

	match (button):
		start_button:
			_on_start_pressed()
			return
		gallery_button:
			_on_gallery_pressed()
			return			
		options_button:
			_on_settings_pressed()
			return
		exit_button:
			_on_exit_pressed()
			return

func _on_start_pressed() -> void:
	transition(func(): SceneTransitionHandler.instance._load_game_scene())

func _on_gallery_pressed() -> void:
	transition(func(): SceneTransitionHandler.instance._load_gallery_scene())

func _on_settings_pressed() -> void:
	button_selection_handler.buttons_origin.hide()

	var settings = settings_scene.instantiate()
	settings.on_back_pressed_type = SettingsMenu.OnBackPressedType.QUEUE_FREE
	settings.on_settings_menu_freed.connect(_on_submenu_closed) 

	submenu_origin.add_child(settings)

	#settings.background.hide()
	#settings.scrolling_background.position = scrolling_background.position

	#Game.game_instance.is_pausable = false

func _on_exit_pressed() -> void:
	transition(func(): get_tree().quit())

func transition(callable: Callable):
	var tween = create_tween()
	tween.tween_property(blackout, "color", Color(0.0, 0.0, 0.0, 1.0), 0.2)
	tween.tween_callback(callable).set_delay(0.2)

func _on_submenu_closed() -> void:
	button_selection_handler._enable_all_buttons()

	button_selection_handler.buttons_origin.modulate = Color(0.0, 0.0, 0.0, 0.0)
	var tween = create_tween().tween_property(button_selection_handler.buttons_origin, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)

	button_selection_handler.buttons_origin.call_deferred("show")