class_name UICompletion extends Control

@export var initial_popup : Control = null
@export var initial_popup_label : RichTextLabel = null

@export var menu : Control = null
@export var menu_button_handler : ButtonSelectionHandler = null

@export var grade_emblem : Grade = null
@export var time_label : Label = null
@export var cash_label : RichTextLabel = null

@export var blackout : ColorRect = null

@export var grade_audio : AudioStreamPlayer = null

var time_elapsed_string : String = "00:00"

var confirmed : bool = false

func _ready() -> void:
	hide()
	initial_popup.hide()
	menu.hide()
	grade_emblem.hide()
	initial_popup.modulate = Color(0.0, 0.0, 0.0, 0.0)
	menu.modulate = Color(0.0, 0.0, 0.0, 0.0)
	menu_button_handler._disable_all_buttons()
	menu_button_handler.on_button_pressed.connect(_transition)
	pass

func _process(delta):
	if (initial_popup.visible):
		initial_popup_label.text = "[center]" + tr("COMPLETION_POPUP_TEXT")

		if (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.GAMEPAD):
			initial_popup_label.text = initial_popup_label.text.replace("[button]", ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("open_inventory")[1]))
		elif (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.KEYBOARD_MOUSE):
			initial_popup_label.text = initial_popup_label.text.replace("[button]", ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("open_inventory")[0]))

	if (confirmed):
		if ((SaveManager.beat_0 and SaveManager.beat_1 and SaveManager.beat_2 and SaveManager.beat_3) and !SaveManager.seen_finale):
			menu_button_handler.buttons[0].text_key = tr("STAGE_NAME_FINALE")

func _show_initial_popup():
	show()
	initial_popup.show()
	var tween = get_tree().create_tween()
	tween.tween_property(initial_popup, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3)

func _show_menu():
	confirmed = true

	initial_popup.hide()
	menu.show()
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(menu, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)

	time_label.text = tr("COMPLETION_TIME_SPENT") + ": " + time_elapsed_string

	menu_button_handler._enable_all_buttons()

	tween.tween_callback(grade_emblem._animate).set_delay(0.6)
	tween.tween_callback(grade_audio.play).set_delay(0.6)

func _transition(button : UIButton):
	menu_button_handler._disable_all_buttons()

	var tween = get_tree().create_tween()
	tween.tween_property(blackout, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)	

	await get_tree().create_timer(0.25).timeout

	if (!(SaveManager.beat_0 and SaveManager.beat_1 and SaveManager.beat_2 and SaveManager.beat_3)):
		SceneTransitionHandler.instance._load_stage_select_scene()
	else:
		if (SaveManager.seen_finale):
			SceneTransitionHandler.instance._load_stage_select_scene()
		else:
			HighscoreManager.current_level_id = 4
			SceneTransitionHandler.instance._load_finale_scene()

	Main.instance.music_manager.currently_playing = Main.instance.music_manager.CurrentlyPlaying.MENU

func _set_grade(a : int):
	grade_emblem.grade = a

func _set_time(a : String):
	time_elapsed_string = a

func _set_cash(a : float):
	cash_label.text = "[center]" + tr("COMPLETION_CASH_EARNED") + " " + CashManager.format_currency(a) + "[img]res://assets/texture/ui/hud/texture_ui_cash_symbol_small.png[/img]"