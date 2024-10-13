class_name Game extends Node3D

@export var player : Player
@export var level : Level
@export var loading_screen : LoadingScreen
@export var ui_completion : Control

static var game_instance : Game = null

func _ready():
	game_instance = self

	level.on_level_completion.connect(_on_level_completion)
	player.global_transform = level.player_spawn_position.global_transform
	player.respawn_transform = level.player_spawn_position.global_transform
	player.leaf_cleaning_handler = level.leaf_population.leaf_cleaning_handler

func _on_loading_ended():
	loading_screen._on_timeout()

func _on_level_completion():
	#TODO: Hide broom on level completion, but allow movement.
	#player._block_input = true
	ui_completion.show()
	Output.print("Level Completed!")