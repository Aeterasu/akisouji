class_name SceneTransitionHandler extends Node

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