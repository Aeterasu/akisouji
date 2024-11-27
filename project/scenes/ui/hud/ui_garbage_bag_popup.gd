class_name UIGarbageBagPopup extends Control

var is_bag_full : bool = false:
	set(value):
		if (is_bag_full == value):
			return

		is_bag_full = value

		if (value):
			var tween = get_tree().create_tween()
			tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)
		else:
			var tween = get_tree().create_tween()
			tween.tween_property(self, "modulate", Color(0.0, 0.0, 0.0, 0.0), 0.1)

func _ready():
	modulate = Color(0.0, 0.0, 0.0, 0.0)