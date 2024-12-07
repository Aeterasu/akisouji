class_name Grade extends Control

@export var d : Control = null
@export var c : Control = null
@export var b : Control = null
@export var a : Control = null
@export var s : Control = null

@export var glow : Control = null

@export var d_color : Color = Color(1.0, 1.0, 1.0)
@export var c_color : Color = Color(1.0, 1.0, 1.0)
@export var b_color : Color = Color(1.0, 1.0, 1.0)
@export var a_color : Color = Color(1.0, 1.0, 1.0)
@export var s_color : Color = Color(1.0, 1.0, 1.0)

var grade : RankingManager.Rank = RankingManager.Rank.D:
	set(value):
		d.hide()
		c.hide()
		b.hide()
		a.hide()
		s.hide()

		match (value):
			0:
				d.show()
				glow.modulate = d_color
			1:
				c.show()
				glow.modulate = c_color
			2:
				b.show()
				glow.modulate = b_color
			3:
				a.show()
				glow.modulate = a_color
			4:
				s.show()
				glow.modulate = s_color


		grade = value

func _animate() -> void:
	#modulate = Color(0.0, 0.0, 0.0, 0.0)
	show()
	glow.show()

	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	#tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)
	tween.tween_property(glow, "modulate", Color(0.0, 0.0, 0.0, 0.0), 1.25)