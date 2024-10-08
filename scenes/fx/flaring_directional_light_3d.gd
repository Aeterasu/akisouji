extends DirectionalLight3D

func _process(delta) -> void:
    if (!WebSunFlare.web_sun_flare):
        return

    WebSunFlare._set_sun_light(self)