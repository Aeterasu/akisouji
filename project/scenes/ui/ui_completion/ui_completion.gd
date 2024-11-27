class_name UICompletion extends Control

@export var initial_popup : Control = null

@export var menu : Control = null
@export var menu_button_handler : ButtonSelectionHandler = null

@export var grade_emblem : Grade = null
@export var time_label : Label = null
@export var cash_label : RichTextLabel = null

@export var blackout : ColorRect = null

var time_elapsed_string : String = "00:00"

var confirmed : bool = false

func _ready() -> void:
	hide()
	initial_popup.hide()
	menu.hide()
	initial_popup.modulate = Color(0.0, 0.0, 0.0, 0.0)
	menu.modulate = Color(0.0, 0.0, 0.0, 0.0)
	menu_button_handler._disable_all_buttons()
	menu_button_handler.on_button_pressed.connect(_transition)
	pass

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
	tween.tween_property(menu, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)

	time_label.text = tr("COMPLETION_TIME_SPENT") + ": " + time_elapsed_string

	menu_button_handler._enable_all_buttons()

func _transition(button : UIButton):
	menu_button_handler._disable_all_buttons()

	var tween = get_tree().create_tween()
	tween.tween_property(blackout, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)	

	await get_tree().create_timer(0.25).timeout

	SceneTransitionHandler.instance._load_stage_select_scene()

func _set_grade(a : int):
	grade_emblem.grade = a

func _set_time(a : String):
	time_elapsed_string = a

func _set_cash(a : float):
	cash_label.text = "[center]" + tr("COMPLETION_CASH_EARNED") + " " + CashManager.format_currency(a) + "[img]res://assets/texture/ui/hud/texture_ui_cash_symbol_small.png[/img]"