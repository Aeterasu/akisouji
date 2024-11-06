class_name StageButton extends Control

@export var stage_scene : PackedScene

@export var highlight : Control = null

@export var name_key : String = ""
@export var description_key : String = ""

var is_selected : bool = false

func _ready():
    highlight.modulate = Color(0.0, 0.0, 0.0)

func _process(delta):
    if (is_selected):
        highlight.modulate = highlight.modulate.lerp(Color(1.0, 1.0, 1.0), 5.0 * delta)
    else:
        highlight.modulate = highlight.modulate.lerp(Color(0.0, 0.0, 0.0), 5.0 * delta)

func _select():
    is_selected = true

func _deselect():
    is_selected = false