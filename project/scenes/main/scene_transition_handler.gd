class_name SceneTransitionHandler extends Node

@export var title_screen_scene : PackedScene = null
@export var game_scene : PackedScene = null
@export var shop_scene : PackedScene = null
@export var gallery_scene : PackedScene = null
@export var stage_select_scene : PackedScene = null

var initialized_scenes : Array[Node] = []

var previous_scene : PackedScene = null

static var instance : SceneTransitionHandler = null

#TODO: make some sort of enum for scene paths
func _ready():
	instance = self

func _clear_scenes() -> void:
	for node in initialized_scenes:
		node.queue_free()

	initialized_scenes.clear()

func _load_scene(path) -> void:
	_clear_scenes()

	var scene = load(path) as PackedScene

	if (!previous_scene):
		previous_scene = scene

	var title_screen = scene.instantiate()
	get_parent().add_child(title_screen)
	initialized_scenes.append(title_screen)

func _load_title_screen_scene() -> void:
	_load_scene(title_screen_scene.resource_path)

func _load_game_scene() -> void:
	_load_scene(game_scene.resource_path)

func _load_shop_scene() -> void:
	_load_scene(shop_scene.resource_path)

func _load_gallery_scene() -> void:
	_load_scene(gallery_scene.resource_path)

func _load_stage_select_scene() -> void:
	_load_scene(stage_select_scene.resource_path)

func _load_previous_scene() -> void:
	_load_scene(previous_scene.resource_path)