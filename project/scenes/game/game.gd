class_name Game extends Node3D

@export var player : Player
@export var level : Level
@export var loading_screen : LoadingScreen
@export var ui_completion : Control
@export var pause_menu : PauseMenu

static var game_instance : Game = null

var is_pausable : bool = true

func _ready():
	game_instance = self

	#level.on_level_completion.connect(_on_level_completion)
	player.global_transform = level.player_spawn_position.global_transform
	player.respawn_transform = level.player_spawn_position.global_transform

	#player.leaf_cleaning_handler = level.leaf_populator.getLeafCleaningHandler()

	loading_screen._on_timeout()

	pause_menu.is_displayed = get_tree().paused

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta):
	if (Input.is_action_just_pressed("pause")):
		toggle_pause()

func _on_loading_ended():
	loading_screen._on_timeout()

func _on_level_completion():
	#TODO: Hide broom on level completion, but allow movement.
	#player._block_input = true
	ui_completion.show()
	Output.print("Level Completed!")

func toggle_pause():
	if (!is_pausable):
		return

	get_tree().paused = !get_tree().paused
	pause_menu.is_displayed = !pause_menu.is_displayed

	if (get_tree().paused):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED