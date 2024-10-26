class_name SettingsSlider extends HSlider

@export var gamepad_step : float = 5

var is_dragging : bool = false

var setting_text = ""

func _ready():
    value_changed.connect(_on_drag)
    drag_started.connect(_on_drag_started)
    drag_ended.connect(_on_drag_ended)

func _on_drag(new_value : float):
    setting_text = str(value)

func _on_drag_started():
    is_dragging = true

func _on_drag_ended(is_value_changed: bool):
    is_dragging = false
