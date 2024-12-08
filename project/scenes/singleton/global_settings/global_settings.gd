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
        if (value < min_mouse_sensitivity):
            value = min_mouse_sensitivity
        elif (value > max_mouse_senitivity):
            value = max_mouse_senitivity

        mouse_sensitivity = value
    get:
        return mouse_sensitivity

@export var min_mouse_sensitivity : float = 0.01
@export var max_mouse_senitivity : float = 1.0

@export_range(1.0, 300.0) var gamepad_sensitvity : float = 64.0:
    set(value):
        if (value < min_gamepad_sensitivity):
            value = min_gamepad_sensitivity
        elif (value > max_gamepad_senitivity):
            value = max_gamepad_senitivity

        gamepad_sensitvity = value
    get:
        return gamepad_sensitvity

@export var min_gamepad_sensitivity : float = 1.0
@export var max_gamepad_senitivity : float = 300.0

@export_range(0.0, 1.0) var gamepad_deadzone : float = 0.3

@export var vsync_enabled : bool = true:
    set(value):
        vsync_enabled = value

        if value:
            DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
        else:
            DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

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

@export var toggle_to_clean : bool = false

@export var camera_wobble_enabled : bool = true

@export var show_fps_counter : bool = true

@export var leaf_highlight_color : Color = Color(0.988, 0.525, 0.259, 1.0)

@export var bindable_actions : Array[String] = []

func _save_config():
    var config = Config.new()
    config.fullscreen = fullscreen
    config.vsync_enabled = vsync_enabled

    config.locale = locale

    config.master_volume = master_volume
    config.sfx_volume = sfx_volume
    config.ambience_volume = ambience_volume
    config.music_volume = music_volume

    config.mouse_sensitivity = mouse_sensitivity
    config.gamepad_sensitvity = gamepad_sensitvity
    config.gamepad_deadzone = gamepad_deadzone

    config.fov = fov

    config.toggle_to_clean = toggle_to_clean
    config.camera_wobble_enabled = camera_wobble_enabled
    config.show_fps_counter = show_fps_counter

    for action in InputMap.get_actions():
        config.input_map[action] = InputMap.action_get_events(action)

    ResourceSaver.save(config, "user://config.tres")

func _load_config():
    var config = load("user://config.tres")

    if (not config):
        return

    fullscreen = config.fullscreen
    vsync_enabled = config.vsync_enabled

    locale = config.locale

    master_volume = config.master_volume
    sfx_volume = config.sfx_volume
    ambience_volume = config.ambience_volume
    music_volume = config.music_volume

    mouse_sensitivity = config.mouse_sensitivity
    gamepad_sensitvity = config.gamepad_sensitvity
    gamepad_deadzone = config.gamepad_deadzone

    fov = config.fov

    toggle_to_clean = config.toggle_to_clean
    camera_wobble_enabled = config.camera_wobble_enabled
    show_fps_counter = config.show_fps_counter

    for action in config.input_map:
        InputMap.action_erase_events(action)
        for input_event in config.input_map[action]:
            InputMap.action_add_event(action, input_event)