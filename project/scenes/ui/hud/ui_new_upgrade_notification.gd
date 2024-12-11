class_name UINewUpgradeNotification extends Control

@export var accent : AudioStreamPlayer = null

@export var big_label : Label = null
@export var small_label : RichTextLabel = null

func _ready():
	modulate = Color(0.0, 0.0, 0.0, 0.0)
	hide()

	_update_label()
	GlobalSettings.on_locale_updated.connect(_update_label)
	InputDeviceCheck.on_device_change.connect(_update_label)

func _process(delta):
	if (Input.is_action_just_pressed("open_inventory")):
		modulate = Color(0.0, 0.0, 0.0, 0.0)
		hide()

func _animate() -> void:
	show()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.25)
	tween.tween_property(self, "modulate", Color(0.0, 0.0, 0.0, 0.0), 0.25).set_delay(4.0)
	tween.tween_callback(hide)

	accent.play()

func _update_label() -> void:
	big_label.text = tr("UPGRADE_NOTIFICATION_1")
	small_label.text = "[center]" + tr("UPGRADE_NOTIFICATION_2")

	if (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.GAMEPAD):
		small_label.text = small_label.text.replace("[button]", ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("open_inventory")[1]))
	elif (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.KEYBOARD_MOUSE):
		small_label.text = small_label.text.replace("[button]", ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("open_inventory")[0]))