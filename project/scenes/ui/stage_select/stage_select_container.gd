class_name StageSelectContainer extends Control

@export var container : HBoxContainer = null
@export var offset : float = 0.0

@export var finale_button : StageButton = null

@export var locked_texture : Texture2D = null

@export var finale_background : TextureRect = null

func _ready() -> void:
	if (!(SaveManager.beat_0 and SaveManager.beat_1 and SaveManager.beat_2 and SaveManager.beat_3)):
		#finale_button.name_key = "FINALE_LOCKED_1"
		#finale_button.description_key = "FINALE_LOCKED_2"
		#(finale_button.get_node("LevelImage") as TextureRect).texture = locked_texture
		#finale_background.texture = locked_texture
		#finale_button.show_highscore = false
		finale_button.queue_free()

func _process(delta):
	container.set("theme_override_constants/separation", _get_target_offset())
	pass

func _get_target_offset():
	return offset * (1 - (1280 / size.x))