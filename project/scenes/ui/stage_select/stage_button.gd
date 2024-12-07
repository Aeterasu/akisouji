class_name StageButton extends Control

@export var level_number : int = 0
@export var stage_scene : PackedScene

@export var highlight : Control = null

@export var name_key : String = ""
@export var description_key : String = ""

@export var grade : Grade = null

var is_selected : bool = false

func _ready():
    highlight.modulate = Color(0.0, 0.0, 0.0)

func _process(delta):
    if (is_selected):
        highlight.modulate = highlight.modulate.lerp(Color(1.0, 1.0, 1.0), 5.0 * delta)
    else:
        highlight.modulate = highlight.modulate.lerp(Color(0.0, 0.0, 0.0), 5.0 * delta)

    level_number = self.get_index()
    grade.grade = HighscoreManager.level_grades[level_number]

func _select():
    is_selected = true

func _deselect():
    is_selected = false