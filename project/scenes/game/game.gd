class_name Game extends Node3D

@export var player : Player
@export var level : Level
@export var ui_completion : Control
@export var pause_menu : PauseMenu
@export var shop_menu_scene : PackedScene = null
@export var shop_origin : Node = null

@export var pausable : Node = null

@export var progress_tracker : LeafProgressTracker = null
@export var particle_handler : LeafParticleHandler = null
@export var audio_handler : LeafAudioHandler = null

@export var ranking_manager : RankingManager = null

@export var rain_effect : Node3D = null

var leaf_populator : LeafPopulator = null
var cleaning_handler : LeafCleaningHandler = null
var last_cleaning_position : Vector3 = Vector3()
var last_cleaning_radius : float = 1.0

var current_level_scene : PackedScene = null

static var game_instance : Game = null

var is_pausable : bool = true

var shop : Shop = null
var is_in_shop : bool = false:
	set(value):
		if (is_in_shop == value):
			return
		
		is_in_shop = value

		if (value):
			_open_shop()
		else:
			_close_shop()

func _ready():
	game_instance = self

	player._block_input = true

	if (!level):
		var node = current_level_scene.instantiate()
		pausable.add_child(node)
		level = node as Level
	

	#level.on_level_completion.connect(_on_level_completion)
	player.global_transform = level.player_spawn_position.global_transform
	player.respawn_transform = level.player_spawn_position.global_transform

	ranking_manager.level = level

	rain_effect.visible = level.enable_rain

	if (is_instance_valid(level.leaf_populator)):
		leaf_populator = level.leaf_populator
		cleaning_handler = leaf_populator.getLeafCleaningHandler()

		progress_tracker.cleaning_handler = cleaning_handler
		cleaning_handler.on_leaves_cleaned.connect(progress_tracker._on_leaves_cleaned)

		player.leaf_cleaning_handler = cleaning_handler

		cleaning_handler.on_leaves_cleaned.connect(particle_handler._on_leaves_cleaned)
		cleaning_handler.on_leaves_cleaned.connect(audio_handler._on_leaves_cleaned)

	progress_tracker.on_completion.connect(_on_level_completion)

	#loading_screen._on_timeout()

	pause_menu.is_displayed = get_tree().paused

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	await get_tree().create_timer(0.4).timeout

	player._block_input = false

func _process(delta):
	if ((not is_in_shop) and (Input.is_action_just_pressed("pause") or (Input.is_action_just_pressed("menu_cancel") and get_tree().paused))):
		toggle_pause()
		player.input_delay = 0.3
		return

	if (!get_tree().paused and Input.is_action_just_pressed("open_inventory")):
		is_in_shop = not is_in_shop
		return

	if (is_in_shop and Input.is_action_just_pressed("open_inventory")):
		_close_shop()
		return

#func _on_loading_ended():
	#loading_screen._on_timeout()

func _on_level_completion():
	#TODO: Hide broom on level completion, but allow movement.

	CashManager._pause_buffer()
	CashManager._grant_cash(level.cash_reward)

	await get_tree().create_timer(1).timeout

	CashManager._clean_buffer()

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

func _open_shop():
	pause_menu.allow_input = false
	get_tree().paused = true

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	shop = shop_menu_scene.instantiate()
	shop.transition_type = Shop.TransitionType.FROM_GAME
	shop_origin.add_child(shop)

	shop.on_shop_closed.connect(_close_shop)

func _close_shop():
	get_tree().paused = false

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	is_in_shop = false

	if (!shop):
		return

	shop.queue_free()

	pause_menu.allow_input = true

	player.input_delay = 0.3

	pause_menu.button_selection_handler._disable_all_buttons()
	await get_tree().create_timer(0.2).timeout
	pause_menu.button_selection_handler._enable_all_buttons()