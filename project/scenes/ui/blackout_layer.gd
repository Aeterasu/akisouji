class_name BlackoutLayer extends Control

@export var black_rect : ColorRect = null
@export var white_rect : ColorRect = null

static var instance : BlackoutLayer = null

func _ready():
	instance = self