class_name PauseMenu extends Control

@export var button_selection_handler : ButtonSelectionHandler = null

@export var resume_button : PaperButton = null
@export var gallery_button : PaperButton = null
@export var options_button : PaperButton = null
@export var exit_button : PaperButton = null

@export var gallery_scene : PackedScene = null
@export var gallery_origin : Node = null

var is_displayed : bool = false:
	set(value):
		is_displayed = value

		var tween = create_tween()
		
		if (is_displayed):
			tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)
			for node in button_selection_handler.buttons:
				node._enable()
			UI.ui_instance.hide()
		else:
			tween.tween_property(self, "modulate", Color(0.0, 0.0, 0.0, 0.0), 0.2)
			for node in button_selection_handler.buttons:
				node._disable()		
			UI.ui_instance.show()

func _ready():
	button_selection_handler.on_button_pressed.connect(_on_button_pressed)
	
func _on_button_pressed(button : PaperButton):
	for node in button_selection_handler.buttons:
		node._disable()

	match (button):
		resume_button:
			_on_resume_pressed()
			return
		gallery_button:
			_on_gallery_pressed()
			return			
		options_button:
			_on_options_pressed()
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
	gallery.on_gallery_freed.connect(_on_gallery_closed) 

	gallery_origin.add_child(gallery)

	Game.game_instance.is_pausable = false

func _on_options_pressed():
	pass

func _on_exit_pressed():
	var tween = create_tween()
	tween.tween_property(BlackoutLayer.instance.black_rect, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)
	tween.tween_callback(func(): SceneTransitionHandler.instance._load_scene("res://scenes/title_screen/title_screen.tscn")).set_delay(0.1)
	get_tree().paused = false

func _on_gallery_closed() -> void:
	for node in button_selection_handler.buttons:
		node._enable()

	Game.game_instance.is_pausable = true