class_name SceneTransitionHandler extends Node

@export var title_screen_scene : PackedScene = null
@export var game_scene : PackedScene = null
@export var shop_scene : PackedScene = null
@export var gallery_scene : PackedScene = null

var initialized_scenes : Array[Node] = []

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

	var title_screen = (load(path) as PackedScene).instantiate()
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