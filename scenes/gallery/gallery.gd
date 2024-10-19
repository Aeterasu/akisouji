extends Control

@export var gallery_base_entry : TextureRect = null
@export var gallery_origin : GridContainer = null

@export var tip_label : Label = null

@export var button_selection_handler : ButtonSelectionHandler = null

@export var back_button : PaperButton = null
@export var open_folder_button : PaperButton = null

func _ready():
	var dir = DirAccess.open("user://")

	button_selection_handler.on_button_pressed.connect(_on_button_pressed)

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