extends Node

@export var fullscreen : bool = false:
    set(value):
        if (value):
            DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
        else:
            DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)

        fullscreen = value

@export var locale : String = "en":
    set (value):
        TranslationServer.set_locale(value)
        locale = value

@export var master_volume : float = 1.0
@export var sfx_volume : float = 1.0
@export var ambience_volume : float = 1.0
@export var music_volume : float = 1.0

@export_range(0.01, 1.0) var mouse_sensitivity : float = 0.125:
    set(value):
        if (value < 0.01):
            value = 0.01
        elif (value > 1.0):
            value = 1.0

        mouse_sensitivity = value

@export_range(1.0, 256.0) var gamepad_sensitvity : float = 64.0
@export_range(0.0, 1.0) var gamepad_deadzone : float = 0.3

@export_range(10.0, 150.0) var fov : float = 75.0:
    set(value):
        if (value < min_fov):
            value = min_fov
        elif (value > max_fov):
            value = max_fov

        fov = value
    get:
        return fov

@export var max_fov : float = 100.0
@export var min_fov : float = 60.0

@export var camera_wobble_enabled : bool = true

@export var show_fps_counter : bool = true

@export var leaf_highlight_color : Color = Color(0.988, 0.525, 0.259, 1.0)