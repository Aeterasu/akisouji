class_name CameraTool extends PlayerTool

@export var mesh : MeshInstance3D = null
@export var camera : Camera3D = null
@export var cooldown : float = 0.4

var cur_cooldown : float = 0.0

@export var audio_shutter : AudioStreamPlayer = null

var tickrate : int = 1
var ticks : int = 0

var wish_photo_mode : bool = false

var block_input : bool = false

signal on_enter_photo_mode
signal on_exit_photo_mode

func _physics_process(delta):
	super(delta)

	cur_cooldown = max(cur_cooldown - delta, 0.0)

	ticks += 1

	if (ticks >= tickrate):
		ticks = 0

func _use_primary() -> void:
	super()

	if (wish_photo_mode and cur_cooldown <= 0.0):
		CameraUI.instance.hide()
		
		var ui_completion_flag : bool = Game.game_instance.ui_completion.visible
		Game.game_instance.ui_completion.hide()
		await get_tree().create_timer(0.1).timeout

		if (ui_completion_flag):
			Game.game_instance.ui_completion.show()

		cur_cooldown = cooldown

		Main.instance._take_screenshot()
		var tween = create_tween()
		tween.tween_property(BlackoutLayer.instance.white_rect, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.05)
		tween.tween_property(BlackoutLayer.instance.white_rect, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5)
		await get_tree().create_timer(0.1).timeout
		CameraUI.instance.show()

		audio_shutter.play()

func _use_secondary() -> void:
	if (block_input):
		return

	super()
	wish_photo_mode = !wish_photo_mode
	allow_switch = !allow_switch
	block_input = true

func _enter_photo_mode() -> void:
	on_enter_photo_mode.emit()
	block_input = false

func _exit_photo_mode() -> void:
	on_exit_photo_mode.emit()
	block_input = false