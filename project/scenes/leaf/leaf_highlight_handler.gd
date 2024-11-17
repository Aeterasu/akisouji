extends Node

@export var leaf_material : StandardMaterial3D = null
@export var highlight_fade_duration = 0.3
@export var highlight_linger_duration = 0.1

var highlight_color : Color = Color(1.0, 1.0, 1.0, 1.0)

var highlight_target_alpha : float = 1.0

func _ready():
	highlight_color = GlobalSettings.leaf_highlight_color
	highlight_target_alpha = GlobalSettings.leaf_highlight_color.a
	highlight_color.a = 0.0

func _physics_process(delta):
	#highlight_color = GlobalSettings.leaf_highlight_color
	# TODO: update on settings change

	if (Input.is_action_just_pressed("hint_highlight")):
		_highlight()

	leaf_material.next_pass.albedo_color = highlight_color

func _highlight():
	var tween = create_tween()
	var highlight = leaf_material.next_pass as StandardMaterial3D
	var color = highlight.albedo_color * leaf_material.albedo_color.a

	tween.tween_property(self, "highlight_color", Color(highlight_color.r, highlight_color.g, highlight_color.b, highlight_target_alpha), highlight_fade_duration)
	tween.tween_property(self, "highlight_color", Color(highlight_color.r, highlight_color.g, highlight_color.b, 0.0), highlight_fade_duration).set_delay(highlight_fade_duration + highlight_linger_duration)