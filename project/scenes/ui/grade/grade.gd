class_name Grade extends Control

@export var d : Control = null
@export var c : Control = null
@export var b : Control = null
@export var a : Control = null
@export var s : Control = null

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
			1:
				c.show()
			2:
				b.show()
			3:
				a.show()
			4:
				s.show()


		grade = value