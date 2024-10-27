class_name Gallery extends Control

@export var on_back_pressed_type : OnBackPressedType = OnBackPressedType.GO_TO_TITLE

@export var gallery_base_entry : TextureRect = null
@export var gallery_origin : GridContainer = null

@export var tip_label : Label = null

@export var button_selection_handler : ButtonSelectionHandler = null

@export var back_button : UIButton = null
@export var open_folder_button : UIButton = null

@export var scroll_container : ScrollContainer = null

@export var gallery_entry_origin : Node = null
@export var gallery_entry_zoom : GalleryEntryZoom = null

@export var gamepad_tooltip : Control = null

var selected_entry_id : int = 0
var entries : Array[GalleryEntry] = []
var selected_entry : GalleryEntry = null

var target_scroll : float = 0.0
var current_scroll : float = 0.0

var enter_keyboard_mode : bool = false

var back_pressed : bool = false

enum OnBackPressedType
{
	GO_TO_TITLE,
	QUEUE_FREE,
}

signal on_gallery_freed

func _ready():
	var dir = DirAccess.open("user://")

	button_selection_handler.on_button_pressed.connect(_on_button_pressed)
	button_selection_handler.on_button_selected.connect(func(): 
		if (selected_entry):
			selected_entry._deselect()
		selected_entry = null)

	var hide_tip : bool = false

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				Output.print("Found directory: " + file_name)
			else:
				var extension = file_name.get_extension()
				if (extension == "png" or extension == "jpg"):
					hide_tip = true
					var image = Image.new()
					image.load(ProjectSettings.globalize_path(dir.get_current_dir()) + file_name)
					var t = ImageTexture.create_from_image(image)
					var t_rect = gallery_base_entry.duplicate()
					gallery_origin.add_child(t_rect)
					t_rect.get_child(0).texture = t

					if (t_rect is GalleryEntry):
						(t_rect as GalleryEntry).on_mouse_selection.connect(_on_entry_mouse_selection)
						(t_rect as GalleryEntry).on_mouse_deselection.connect(_on_entry_mouse_deselection)
						entries.append(t_rect as GalleryEntry)
			file_name = dir.get_next()

		gallery_base_entry.queue_free()
	else:
		Output.print("An error occurred when trying to access the path.")

	if (hide_tip):
		tip_label.hide()

	modulate = Color(0.0, 0.0, 0.0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0), 0.3)

	InputDeviceCheck.on_device_change.connect(_on_input_device_change)

	_on_input_device_change()

func _process(delta):
	if (!gallery_entry_zoom.is_displayed and selected_entry and Input.is_action_just_pressed("menu_confirm")):
		gallery_entry_zoom._display(selected_entry.get_child(0).texture)

		if (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.KEYBOARD_MOUSE and !enter_keyboard_mode):
			selected_entry._deselect()
			selected_entry = null

		return

	if (gallery_entry_zoom.is_displayed and (Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("menu_confirm") or Input.is_action_just_pressed("menu_cancel"))):
		gallery_entry_zoom._undisplay()
		return		

	gallery_origin.columns = max(floor(get_viewport_rect().size.x / get_viewport_rect().size.y * 3) - 1, 1)

	if (Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("menu_cancel")):
		_on_back_pressed()

	if (!enter_keyboard_mode and Input.is_action_just_pressed("player_move_forward") and InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.KEYBOARD_MOUSE):
		enter_keyboard_mode = true
		_on_input_device_change()

	if (!gallery_entry_zoom.is_displayed and (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.GAMEPAD or (enter_keyboard_mode and InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.KEYBOARD_MOUSE))):
		if (Input.is_action_just_pressed("gamepad_dpad_right") or Input.is_action_just_pressed("player_move_right")):
			selected_entry_id += 1
			_update_selected_entry_id()
		if (Input.is_action_just_pressed("gamepad_dpad_left") or Input.is_action_just_pressed("player_move_left")):
			selected_entry_id -= 1
			_update_selected_entry_id()
		if (Input.is_action_just_pressed("gamepad_dpad_up") or Input.is_action_just_pressed("player_move_forward")):
			selected_entry_id -= gallery_origin.columns
			_update_selected_entry_id()
		if (Input.is_action_just_pressed("gamepad_dpad_down") or Input.is_action_just_pressed("player_move_backwards")):
			selected_entry_id += gallery_origin.columns
			_update_selected_entry_id()

		current_scroll = lerp(current_scroll, target_scroll, 6.0 * delta)
		scroll_container.scroll_vertical = int(current_scroll)
	
	if (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.GAMEPAD or (enter_keyboard_mode and InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.KEYBOARD_MOUSE)):
		current_scroll = scroll_container.scroll_vertical

func _update_selected_entry_id():
	if (is_instance_valid(selected_entry)):
		selected_entry._deselect()

	if (selected_entry_id < 0):
		selected_entry_id = 0
	elif (selected_entry_id > len(entries) - 1):
		selected_entry_id = len(entries) - 1

	selected_entry = entries[selected_entry_id]
	selected_entry._select()

	var y_offset = 240

	if (selected_entry.position.y > target_scroll + y_offset):
		target_scroll = selected_entry.position.y - y_offset
	elif (selected_entry.position.y < target_scroll):
		target_scroll = selected_entry.position.y

func load_image_texture(path: String) -> ImageTexture:
	
	var loaded_image := Image.new()
	var error := loaded_image.load(path)
	
	if error != OK:
		return null

	return ImageTexture.create_from_image(loaded_image)

func _on_button_pressed(button : UIButton):
	button_selection_handler._disable_all_buttons()

	match (button):
		back_button:
			_on_back_pressed()
			return
		open_folder_button:
			_on_open_folder_pressed()
			return

func _on_back_pressed() -> void:
	if (enter_keyboard_mode):
		if (selected_entry):
			selected_entry._deselect()
			selected_entry = null

		enter_keyboard_mode = false
		_on_input_device_change()
		return

	InputDeviceCheck.on_device_change.disconnect(_on_input_device_change)

	match on_back_pressed_type:
		OnBackPressedType.GO_TO_TITLE:
			transition(func(): SceneTransitionHandler.instance._load_scene("res://scenes/ui/title_screen/title_screen.tscn"))
		OnBackPressedType.QUEUE_FREE:
			on_gallery_freed.emit()
			self.queue_free()

func _on_open_folder_pressed() -> void:
	if (OS.get_name() == "Web"):
		return

	OS.shell_open(ProjectSettings.globalize_path("user://"))

func transition(callable: Callable):
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(0.0, 0.0, 0.0), 0.2)
	tween.tween_callback(callable).set_delay(0.2)

func _on_entry_mouse_selection(entry : GalleryEntry):
	button_selection_handler.current_selection_id = -999
	button_selection_handler._update_button()	
	selected_entry = entry
	entry._select()

func _on_entry_mouse_deselection(entry : GalleryEntry):
	selected_entry = null
	entry._deselect()

func _on_input_device_change():
	if (back_pressed):
		return

	if (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.GAMEPAD):
		button_selection_handler._disable_all_buttons()
		button_selection_handler.buttons_origin.hide()
		scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
		enter_keyboard_mode = false
	elif (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.KEYBOARD_MOUSE and enter_keyboard_mode):
		button_selection_handler._disable_all_buttons()
		button_selection_handler.buttons_origin.hide()
		scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	elif (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.KEYBOARD_MOUSE):
		button_selection_handler._enable_all_buttons()
		button_selection_handler.buttons_origin.show()
		scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO