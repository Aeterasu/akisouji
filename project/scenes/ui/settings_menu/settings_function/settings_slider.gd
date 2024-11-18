class_name SettingsSlider extends HSlider

@export var gamepad_step : float = 5

@export var accent_cooldown : float = 0.1

var is_dragging : bool = false

var setting_text = ""

var slide_accent_audio : AudioStream = null
var accent_player : AudioStreamPlayer = AudioStreamPlayer.new()

var accent_tick : float = 0.0

func _ready():
    value_changed.connect(_on_drag)
    drag_started.connect(_on_drag_started)
    drag_ended.connect(_on_drag_ended)

    slide_accent_audio = load("res://assets/audio/sfx_typing_1.ogg")
    accent_player.bus = "SFX"
    accent_player.volume_db = -8
    add_child(accent_player)

    accent_player.set_deferred("stream", slide_accent_audio)

func _physics_process(delta):
    accent_tick += delta

func _on_drag(new_value : float):
    #setting_text = str(value)
    if (accent_tick >= accent_cooldown):
        accent_player.play()
        accent_tick = 0.0

func _on_drag_started():
    is_dragging = true

func _on_drag_ended(is_value_changed: bool):
    is_dragging = false
