extends Node3D

@export var animation_player : AnimationPlayer = null
@export var blackout : ColorRect = null

var can_exit : bool = false

var exiting : bool = false

func _ready() -> void:
	animation_player.play("pan")

	blackout.modulate = Color(1.0, 1.0, 1.0, 1.0)

	var tween = get_tree().create_tween()
	tween.tween_property(blackout, "modulate", Color(0.0, 0.0, 0.0, 0.0), 0.2)

func _input(event):
	if (event.is_pressed()):
		if (not exiting and event is InputEventJoypadButton or event is InputEventKey or event is InputEventMouseButton):
			_exit()

func _allow_exit() -> void:
	can_exit = true

func _exit() -> void:
	exiting = true

	HighscoreManager._update_current_level_grade(RankingManager.Rank.S, 999999999)
	
	var tween = get_tree().create_tween()
	tween.tween_property(blackout, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.4)

	tween.tween_callback(SceneTransitionHandler.instance._load_title_screen_scene).set_delay(0.45)