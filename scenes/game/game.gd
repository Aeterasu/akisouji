class_name Game extends Node3D

@export var loading_screen : LoadingScreen

static var game_instance : Game = null

func _ready():
	game_instance = self

func _on_loading_ended():
	loading_screen._on_timeout()