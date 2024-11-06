class_name SceneTransitionHandler extends Node

@export var title_screen_scene : PackedScene = null
@export var game_scene : PackedScene = null
@export var shop_scene : PackedScene = null
@export var gallery_scene : PackedScene = null
@export var stage_select_scene : PackedScene = null

var initialized_scenes : Array[Node] = []

var previous_scene : PackedScene = null

var current_scene : PackedScene = null

static var instance : SceneTransitionHandler = null

func _ready():
	instance = self

func _clear_scenes() -> void:
	for node in initialized_scenes:
		node.queue_free()

	initialized_scenes.clear()

func _load_scene(path, is_game : bool = false, level_scene : PackedScene = null) -> void:
	previous_scene = current_scene

	_clear_scenes()

	var scene = load(path) as PackedScene

	var node = scene.instantiate()

	if (node is Game):
		node.current_level_scene = level_scene

	get_parent().add_child(node)
	initialized_scenes.append(node)
	current_scene = scene

func _load_title_screen_scene() -> void:
	_load_scene(title_screen_scene.resource_path)

func _load_game_scene(level : PackedScene) -> void:
	_load_scene(game_scene.resource_path, true, level)

func _load_shop_scene() -> void:
	_load_scene(shop_scene.resource_path)

func _load_gallery_scene() -> void:
	_load_scene(gallery_scene.resource_path)

func _load_stage_select_scene() -> void:
	_load_scene(stage_select_scene.resource_path)

func _load_previous_scene() -> void:
	_load_scene(previous_scene.resource_path)