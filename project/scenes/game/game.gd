class_name Game extends Node3D

@export var player : Player
@export var level : Level
@export var ui_completion : UICompletion
@export var pause_menu : PauseMenu
@export var shop_menu_scene : PackedScene = null
@export var shop_origin : Node = null

@export var pausable : Node = null

@export var progress_tracker : LeafProgressTracker = null
@export var particle_handler : LeafParticleHandler = null
@export var audio_handler : LeafAudioHandler = null

@export var ranking_manager : RankingManager = null

@export var rain_effect : Node3D = null

@export var ui_layer : CanvasLayer = null

var leaf_populator : LeafPopulator = null
var cleaning_handler : LeafCleaningHandler = null
var last_cleaning_position : Vector3 = Vector3()
var last_cleaning_radius : float = 1.0

var current_level_scene : PackedScene = null

var await_completion_confirm : bool = false

static var game_instance : Game = null

var is_pausable : bool = true

var shop : Shop = null
var is_in_shop : bool = false

var cash_earned : float = 0.0

func _ready():
	CashManager.finalize = false

	game_instance = self

	ui_layer.show()

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

		cleaning_handler.on_leaves_cleaned.connect(player._on_leaves_cleaned)

		#cleaning_handler.on_leaves_cleaned.connect(func(amount: int): CashManager._substract_cash(float(amount) * CashManager.golden_broom_consumption))

	progress_tracker.leeway = level.leaf_leeway

	progress_tracker.on_completion.connect(_on_level_completion)

	pause_menu.is_displayed = get_tree().paused

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	await get_tree().create_timer(0.4).timeout

	player._block_input = false

	shop_origin.hide()

	#get_viewport().debug_draw = Viewport.DEBUG_DRAW_OVERDRAW
	#get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME

	for i in 15:
		Game.game_instance.cleaning_handler.RequestCleaningAtPosition(Vector2.ZERO, Vector2.ZERO, Vector2.ZERO)

func _process(delta):
	if (await_completion_confirm and Input.is_action_just_pressed("open_inventory") and !ui_completion.confirmed):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		player._block_input = true
		ui_completion._set_grade(ranking_manager.get_current_rank())
		ui_completion._set_time(ranking_manager.get_formatted_time_elapsed())
		ui_completion._set_cash(cash_earned)
		ui_completion._show_menu()
		UI.instance.hide()
		return

	if (await_completion_confirm):
		return

	if (!pause_menu.is_displayed and !is_in_shop and Input.is_action_just_pressed("open_inventory")):
		is_in_shop = true
		_open_shop()
		is_pausable = false
		return

	if (shop and is_in_shop and Input.is_action_just_pressed("open_inventory")):
		shop._on_back_button_pressed()
		
		return

	if ((not is_in_shop) and (Input.is_action_just_pressed("pause") or (Input.is_action_just_pressed("menu_cancel") and pause_menu.is_displayed))):
		toggle_pause()
		player.input_delay = 0.3
		return

func _on_level_completion():
	CashManager.finalize = true
	CashManager._grant_cash(level.cash_reward + ranking_manager._get_current_cash_bonus(), 8.0)

	ranking_manager.completed = true

	await get_tree().create_timer(1).timeout

	ui_completion._show_initial_popup()
	await_completion_confirm = true

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
	shop_origin.show()

	shop.on_shop_closed.connect(_close_shop)

func _close_shop():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	is_in_shop = false

	if (!shop):
		return

	shop.queue_free()

	shop_origin.hide()

	pause_menu.allow_input = true

	player.input_delay = 0.3

	pause_menu.button_selection_handler._disable_all_buttons()
	await get_tree().create_timer(0.2).timeout
	pause_menu.button_selection_handler._enable_all_buttons()