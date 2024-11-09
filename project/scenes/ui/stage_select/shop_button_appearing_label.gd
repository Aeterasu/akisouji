extends Control

@export var shop_button : UIButton = null

var is_selected : bool = false

func _ready() -> void:
	shop_button.on_selected.connect(_on_selected)
	shop_button.on_deselected.connect(_on_deselected)

	modulate = Color(0.0, 0.0, 0.0, 0.0)

func _process(delta):
	if (is_selected):
		modulate = modulate.lerp(Color(1.0, 1.0, 1.0, 1.0), 5 * delta)
	else:
		modulate = modulate.lerp(Color(0.0, 0.0, 0.0, 0.0), 16 * delta)

func _on_selected(button : UIButton) -> void:
	is_selected = true

func _on_deselected(button : UIButton) -> void:
	is_selected = false