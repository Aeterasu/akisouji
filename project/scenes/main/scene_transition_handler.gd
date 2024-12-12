class_name SceneTransitionHandler extends Node

@export var title_screen_scene : PackedScene = null
@export var game_scene_path = "res://scenes/game/game.tscn"
@export var shop_scene : PackedScene = null
@export var gallery_scene : PackedScene = null
@export var stage_select_scene : PackedScene = null
@export var finale_scene_path = "res://scenes/level/finale/level_finale.tscn"

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
	var tween = create_tween()
	tween.tween_callback(Main.instance.loading_screen.show)
	tween.tween_property(Main.instance.loading_screen, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.35)

	await get_tree().create_timer(0.35).timeout

	_load_scene(game_scene_path, true, level)

	tween.stop()
	tween.tween_property(Main.instance.loading_screen, "modulate", Color(0.0, 0.0, 0.0, 0.0), 0.35)
	tween.tween_callback(Main.instance.loading_screen.hide)
	tween.play()

func _load_shop_scene() -> void:
	_load_scene(shop_scene.resource_path)

func _load_gallery_scene() -> void:
	_load_scene(gallery_scene.resource_path)

func _load_stage_select_scene() -> void:
	_load_scene(stage_select_scene.resource_path)

func _load_finale_scene() -> void:
	var tween = create_tween()
	tween.tween_callback(Main.instance.loading_screen.show)
	tween.tween_property(Main.instance.loading_screen, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)

	await get_tree().create_timer(0.2).timeout

	_load_scene(finale_scene_path)

	tween.stop()
	tween.tween_property(Main.instance.loading_screen, "modulate", Color(0.0, 0.0, 0.0, 0.0), 0.2)
	tween.tween_callback(Main.instance.loading_screen.hide)
	tween.play()

func _load_previous_scene() -> void:
	_load_scene(previous_scene.resource_path)