extends Node

@export var enabled : bool = true

@export var leaf_material : StandardMaterial3D = null

@export var highlight_duration : float = 1.0
@export var lerp_weight : float = 6.0

var highlight_color : Color = Color(1.0, 1.0, 1.0, 1.0)

var highlight_target_alpha : float = 1.0

var highlight_time_left : float = 0.0

func _ready():
	highlight_color = GlobalSettings.leaf_highlight_color
	highlight_target_alpha = GlobalSettings.leaf_highlight_color.a
	highlight_color.a = 0.0

func _process(delta):
	# TODO: update on settings change

	if (enabled and Input.is_action_just_pressed("hint_highlight")):
		_highlight()

	highlight_time_left = max(highlight_time_left - delta, 0.0)
	
	if (highlight_time_left > 0.0):
		highlight_color = highlight_color.lerp(Color(highlight_color.r, highlight_color.g, highlight_color.b, highlight_target_alpha), lerp_weight * delta)
	else:
		highlight_color = highlight_color.lerp(Color(highlight_color.r, highlight_color.g, highlight_color.b, 0.0), lerp_weight * delta)

	(leaf_material.next_pass as ShaderMaterial).set_shader_parameter("highlight_color", highlight_color)

func _highlight():
	highlight_time_left = highlight_duration