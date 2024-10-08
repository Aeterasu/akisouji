class_name WebSunFlare extends ColorRect

@export var sun_light: DirectionalLight3D = null

static var web_sun_flare : WebSunFlare = null

func _ready():
	web_sun_flare = self

func _process(delta) -> void:
	if (!sun_light):
		return

	var active_camera = get_viewport().get_camera_3d()
	var effective_sun_direction : Vector3 = sun_light.global_transform.basis.z * maxf(active_camera.near, 1.0)
	effective_sun_direction += active_camera.global_transform.origin

	visible = not active_camera.is_position_behind(effective_sun_direction)

	if (visible):
		var unprojected_sun_position : Vector2 = active_camera.unproject_position(effective_sun_direction)
		self.material.set_shader_parameter("sun_position", unprojected_sun_position)

static func _set_sun_light(sun : DirectionalLight3D) -> void:
	web_sun_flare.sun_light = sun