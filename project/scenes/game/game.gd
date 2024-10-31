class_name Game extends Node3D

@export var player : Player
@export var level : Level
@export var loading_screen : LoadingScreen
@export var ui_completion : Control
@export var pause_menu : PauseMenu

@export var progress_tracker : LeafProgressTracker = null
@export var particle_handler : LeafParticleHandler = null

var leaf_populator : LeafPopulator = null
var cleaning_handler : LeafCleaningHandler = null
var last_cleaning_position : Vector3 = Vector3()
var last_cleaning_radius : float = 1.0

static var game_instance : Game = null

var is_pausable : bool = true

func _ready():
	game_instance = self

	player._block_input = true

	#level.on_level_completion.connect(_on_level_completion)
	player.global_transform = level.player_spawn_position.global_transform
	player.respawn_transform = level.player_spawn_position.global_transform

	if (is_instance_valid(level.leaf_populator)):
		leaf_populator = level.leaf_populator
		cleaning_handler = leaf_populator.getLeafCleaningHandler()

		progress_tracker.cleaning_handler = cleaning_handler
		cleaning_handler.on_leaves_cleaned.connect(progress_tracker._on_leaves_cleaned)

		player.leaf_cleaning_handler = cleaning_handler

		cleaning_handler.on_leaves_cleaned.connect(particle_handler._on_leaves_cleaned)

	progress_tracker.on_completion.connect(_on_level_completion)

	loading_screen._on_timeout()

	pause_menu.is_displayed = get_tree().paused

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	await get_tree().create_timer(0.4).timeout

	player._block_input = false

func _process(delta):
	if (Input.is_action_just_pressed("pause") or (Input.is_action_just_pressed("menu_cancel") and get_tree().paused)):
		toggle_pause()
		player.block_brooming_until_key_is_released = true

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
		pause_menu.button_selection_handler._disable_all_buttons()
		await get_tree().create_timer(0.05).timeout
		pause_menu.button_selection_handler._enable_all_buttons()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED