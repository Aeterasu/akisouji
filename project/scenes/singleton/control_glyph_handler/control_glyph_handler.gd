extends Node

@export var glyph_image : Texture2D = null

func _get_glyph_image_path() -> String:
	return glyph_image.resource_path