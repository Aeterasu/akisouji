extends Control

@export var button_start : Button = null
@export var button_options : Button = null
@export var button_exit : Button = null

func _ready():
	button_start.pressed.connect(_on_start_pressed)
	button_options.pressed.connect(_on_options_pressed)
	button_exit.pressed.connect(_on_exit_pressed)

func _on_start_pressed() -> void:
	SceneTransitionHandler.instance._load_scene("res://scenes/game/game.tscn")

func _on_options_pressed() -> void:
	pass

func _on_exit_pressed() -> void:
	get_tree().quit()