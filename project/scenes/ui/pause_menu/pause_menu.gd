class_name PauseMenu extends Control

@export var scrolling_background : Control = null

@export var button_selection_handler : ButtonSelectionHandler = null

@export var resume_button : UIButton = null
@export var gallery_button : UIButton = null
@export var options_button : UIButton = null
@export var exit_button : UIButton = null

@export var submenu_origin : Node = null

@export var gallery_scene : PackedScene = null
@export var settings_scene : PackedScene = null

var is_displayed : bool = false:
	set(value):
		is_displayed = value

		var tween = create_tween()
		
		if (is_displayed):
			tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)
			for node in button_selection_handler.buttons:
				node._enable()
			UI.instance.hide()
			button_selection_handler._enable_all_buttons()
		else:
			tween.tween_property(self, "modulate", Color(0.0, 0.0, 0.0, 0.0), 0.2)
			for node in button_selection_handler.buttons:
				node._disable()		
			UI.instance.show()

func _ready():
	button_selection_handler.on_button_pressed.connect(_on_button_pressed)

	button_selection_handler._disable_all_buttons()

	await get_tree().create_timer(0.05).timeout
	button_selection_handler._enable_all_buttons()
	
func _on_button_pressed(button : UIButton):
	button_selection_handler._disable_all_buttons()

	match (button):
		resume_button:
			_on_resume_pressed()
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

func _on_resume_pressed():
	Game.game_instance.toggle_pause()
	button_selection_handler.current_selection_id = -999
	button_selection_handler._update_button()

func _on_gallery_pressed():
	var gallery = gallery_scene.instantiate()
	gallery.on_back_pressed_type = Gallery.OnBackPressedType.QUEUE_FREE
	gallery.on_gallery_freed.connect(_on_submenu_closed) 

	submenu_origin.add_child(gallery)

	Game.game_instance.is_pausable = false

func _on_settings_pressed():
	self.hide()

	var settings = settings_scene.instantiate()
	settings.on_back_pressed_type = SettingsMenu.OnBackPressedType.QUEUE_FREE
	settings.on_settings_menu_freed.connect(_on_submenu_closed) 

	submenu_origin.add_child(settings)

	#settings.background.hide()
	settings.scrolling_background.position = scrolling_background.position

	Game.game_instance.is_pausable = false

func _on_exit_pressed():
	var tween = create_tween()
	tween.tween_property(BlackoutLayer.instance.black_rect, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)
	tween.tween_callback(func(): SceneTransitionHandler.instance._load_scene("res://scenes/ui/title_screen/title_screen.tscn")).set_delay(0.1)
	get_tree().paused = false

func _on_submenu_closed() -> void:
	for node in button_selection_handler.buttons:
		node._enable()

	Game.game_instance.is_pausable = true
	button_selection_handler._enable_all_buttons()

	self.show()