extends Control

@export var gallery_base_entry : TextureRect = null
@export var gallery_origin : GridContainer = null

@export var tip_label : Label = null

@export var button_selection_handler : ButtonSelectionHandler = null

@export var back_button : PaperButton = null
@export var open_folder_button : PaperButton = null

@export var gallery_entry_zoom : GalleryEntryZoom = null

var selected_entry : GalleryEntry = null

func _ready():
	var dir = DirAccess.open("user://")

	button_selection_handler.on_button_pressed.connect(_on_button_pressed)
	button_selection_handler.on_button_selected.connect(func(): 
		if (selected_entry):
			selected_entry._deselect()
		selected_entry = null)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				Output.print("Found directory: " + file_name)
			else:
				if (file_name.get_extension() == "png"):
					var image = Image.new()
					image.load(ProjectSettings.globalize_path(dir.get_current_dir()) + file_name)
					var t = ImageTexture.create_from_image(image)
					var t_rect = gallery_base_entry.duplicate()
					gallery_origin.add_child(t_rect)
					t_rect.get_child(0).texture = t

					if (t_rect is GalleryEntry):
						(t_rect as GalleryEntry).on_mouse_selection.connect(_on_entry_mouse_selection)
						(t_rect as GalleryEntry).on_mouse_deselection.connect(_on_entry_mouse_deselection)
			file_name = dir.get_next()

		gallery_base_entry.queue_free()
	else:
		Output.print("An error occurred when trying to access the path.")

	if (gallery_origin.get_child_count() >= 1):
		tip_label.hide()

	modulate = Color(0.0, 0.0, 0.0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0), 0.3)

func _process(delta):
	if (!gallery_entry_zoom.is_displayed and selected_entry and Input.is_action_just_pressed("menu_confirm")):
		gallery_entry_zoom._display(selected_entry.get_child(0).texture)
		selected_entry._deselect()
		selected_entry = null
		return

	if (gallery_entry_zoom.is_displayed and (Input.is_action_just_pressed("menu_confirm") or Input.is_action_just_pressed("menu_cancel"))):
		gallery_entry_zoom._undisplay()
		return		

	gallery_origin.columns = max(floor(get_viewport_rect().size.x / get_viewport_rect().size.y * 3) - 1, 1)

	#scroll bar hugs the gallery entries in non 16:9 resolution. no, I don't know how to fix that.

	#var vscroll = (gallery_origin.get_parent() as ScrollContainer).get_v_scroll_bar()
	#vscroll.top_level = true
	#vscroll.z_index = -1
	#vscroll.position.x = get_viewport_rect().size.x - (32.0 * (get_viewport_rect().size.x / 1280.0))
	#vscroll.position.y = 64.0
	#vscroll.size.y = (gallery_origin.get_parent() as ScrollContainer).size.y * 2
	#var x_margin = 32.0 + gallery_origin.size / gallery_origin.columns
	#gallery_origin.set("theme_override_constants/h_separation", x_margin)
	#print(x_margin)

func load_image_texture(path: String) -> ImageTexture:
	
	var loaded_image := Image.new()
	var error := loaded_image.load(path)
	
	if error != OK:
		return null

	return ImageTexture.create_from_image(loaded_image)

func _on_button_pressed(button : PaperButton):
	for node in button_selection_handler.buttons:
		node._disable()

	match (button):
		back_button:
			_on_back_pressed()
			return
		open_folder_button:
			_on_open_folder_pressed()
			return

func _on_back_pressed() -> void:
	transition(func(): SceneTransitionHandler.instance._load_scene("res://scenes/title_screen/title_screen.tscn"))

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
	entry._deselect()