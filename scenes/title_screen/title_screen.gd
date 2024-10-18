extends Control

@export var button_selection_handler : ButtonSelectionHandler = null

@export var start_button : PaperButton = null
@export var gallery_button : PaperButton = null
@export var options_button : PaperButton = null
@export var exit_button : PaperButton = null

func _ready():
	button_selection_handler.on_button_pressed.connect(_on_button_pressed)

	modulate = Color(0.0, 0.0, 0.0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0), 0.3)

func _on_button_pressed(button : PaperButton):
	match (button):
		start_button:
			_on_start_pressed()
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

func _on_start_pressed() -> void:
	transition(func(): SceneTransitionHandler.instance._load_scene("res://scenes/game/game.tscn"))

func _on_gallery_pressed() -> void:
	transition(func(): SceneTransitionHandler.instance._load_scene("res://scenes/gallery/gallery.tscn"))

func _on_options_pressed() -> void:
	pass

func _on_exit_pressed() -> void:
	transition(func(): get_tree().quit())

func transition(callable: Callable):
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(0.0, 0.0, 0.0), 0.2)
	tween.tween_callback(callable).set_delay(0.2)