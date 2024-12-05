class_name PlayerToolInventory extends Node

@export var tool_origin : Node = null
@export var swap_cooldown : float = 0.1

@export var player : Player = null

var current_tool : PlayerTool = null
var current_tool_id : int = 0
var tools : Array[PlayerTool] = []

var swap_cooldown_timer : Timer = Timer.new()

func _ready():
	for node in tool_origin.get_children():
		if (node is PlayerTool):
			tools.append(node)

	current_tool = tools[0]

	add_child(swap_cooldown_timer)
	swap_cooldown_timer.one_shot = true

	await get_tree().create_timer(0.05).timeout

	_update_hud_textures()

func _update_hud_textures() -> void:
	UI.instance.ui_tool_carousel.tool_center.texture = current_tool.hud_icon
	UI.instance.ui_tool_carousel.tool_left.texture = tools[wrapi(current_tool_id - 1, 0, len(tools))].hud_icon
	UI.instance.ui_tool_carousel.tool_right.texture = tools[wrapi(current_tool_id + 1, 0, len(tools))].hud_icon

	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_callback(func(): UI.instance.ui_tool_carousel.tool_center.position.x = 1033.0).set_delay(0.2)
	tween.tween_callback(func(): (UI.instance.ui_tool_carousel.tool_center.material as ShaderMaterial).set_shader_parameter("modulate", Color(1.0, 1.0, 1.0, 1.0))).set_delay(0.2)
	tween.tween_callback(func(): (UI.instance.ui_tool_carousel.tool_center.material as ShaderMaterial).set_shader_parameter("coeff", 0.00)).set_delay(0.2)

	tween.tween_callback(func(): UI.instance.ui_tool_carousel.tool_left.position.x = 945.0).set_delay(0.2)
	tween.tween_callback(func(): (UI.instance.ui_tool_carousel.tool_left.material as ShaderMaterial).set_shader_parameter("modulate", UI.instance.ui_tool_carousel.semi_transparent_color)).set_delay(0.2)
	tween.tween_callback(func(): (UI.instance.ui_tool_carousel.tool_left.material as ShaderMaterial).set_shader_parameter("coeff", 0.2)).set_delay(0.2)

	tween.tween_callback(func(): UI.instance.ui_tool_carousel.tool_right.position.x = 1121.0).set_delay(0.2)
	tween.tween_callback(func(): (UI.instance.ui_tool_carousel.tool_right.material as ShaderMaterial).set_shader_parameter("modulate", UI.instance.ui_tool_carousel.semi_transparent_color)).set_delay(0.2)
	tween.tween_callback(func(): (UI.instance.ui_tool_carousel.tool_right.material as ShaderMaterial).set_shader_parameter("coeff", 0.2)).set_delay(0.2)

	tween.tween_callback(func(): UI.instance.ui_tool_carousel.tool_left_animated.position.x = 857.0).set_delay(0.2)
	tween.tween_callback(func(): (UI.instance.ui_tool_carousel.tool_left_animated.material as ShaderMaterial).set_shader_parameter("modulate", Color(0.0, 0.0, 0.0, 0.0))).set_delay(0.2)
	tween.tween_callback(func(): (UI.instance.ui_tool_carousel.tool_left_animated.material as ShaderMaterial).set_shader_parameter("coeff", 0.8)).set_delay(0.2)

	tween.tween_callback(func(): UI.instance.ui_tool_carousel.tool_right_animated.position.x = 1209.0).set_delay(0.2)
	tween.tween_callback(func(): (UI.instance.ui_tool_carousel.tool_right_animated.material as ShaderMaterial).set_shader_parameter("modulate", Color(0.0, 0.0, 0.0, 0.0))).set_delay(0.2)
	tween.tween_callback(func(): (UI.instance.ui_tool_carousel.tool_right_animated.material as ShaderMaterial).set_shader_parameter("coeff", 0.8)).set_delay(0.2)

func _physics_process(delta) -> void:
	if (current_tool):
		UI.instance.ui_tool_carousel.label.text = tr(current_tool.tool_name)

	if (current_tool and !current_tool.allow_switch):
		return

	if (!player._block_input and !player.garbage_bag_handler.is_holding_a_bag and swap_cooldown_timer.is_stopped()):
		if (Input.is_action_just_pressed("player_action_next_tool")):
			_next_tool()

			UI.instance.ui_tool_carousel.audio_accent_1.play()

			var tween = create_tween()
			tween.set_parallel(true)

			tween.tween_property(UI.instance.ui_tool_carousel.tool_center, "position", Vector2(1121.0, UI.instance.ui_tool_carousel.tool_center.position.y), 0.2)
			tween.tween_property(UI.instance.ui_tool_carousel.tool_center.material, "shader_parameter/modulate", UI.instance.ui_tool_carousel.semi_transparent_color, 0.2)
			tween.tween_property(UI.instance.ui_tool_carousel.tool_center.material, "shader_parameter/coeff", 0.2, 0.2)
			tween.tween_callback(func(): UI.instance.ui_tool_carousel.tool_center.position.x = 1033.0).set_delay(0.2)
			tween.tween_callback(func(): (UI.instance.ui_tool_carousel.tool_center.material as ShaderMaterial).set_shader_parameter("modulate", Color(1.0, 1.0, 1.0, 1.0))).set_delay(0.2)
			tween.tween_callback(func(): (UI.instance.ui_tool_carousel.tool_center.material as ShaderMaterial).set_shader_parameter("coeff", 0.00)).set_delay(0.2)

			tween.tween_callback(func(): UI.instance.ui_tool_carousel.tool_center.texture = current_tool.hud_icon).set_delay(0.2)

			tween.tween_property(UI.instance.ui_tool_carousel.tool_left, "position", Vector2(1033.0, UI.instance.ui_tool_carousel.tool_left.position.y), 0.2)
			tween.tween_property(UI.instance.ui_tool_carousel.tool_left.material, "shader_parameter/modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)
			tween.tween_property(UI.instance.ui_tool_carousel.tool_left.material, "shader_parameter/coeff", 0.00, 0.2)
			tween.tween_callback(func(): UI.instance.ui_tool_carousel.tool_left.position.x = 945.0).set_delay(0.2)
			tween.tween_callback(func(): (UI.instance.ui_tool_carousel.tool_left.material as ShaderMaterial).set_shader_parameter("modulate", UI.instance.ui_tool_carousel.semi_transparent_color)).set_delay(0.2)
			tween.tween_callback(func(): (UI.instance.ui_tool_carousel.tool_left.material as ShaderMaterial).set_shader_parameter("coeff", 0.2)).set_delay(0.2)

			tween.tween_callback(func(): UI.instance.ui_tool_carousel.tool_left.texture = tools[current_tool_id - 1].hud_icon).set_delay(0.2)

			tween.tween_property(UI.instance.ui_tool_carousel.tool_right, "position", Vector2(1209.0, UI.instance.ui_tool_carousel.tool_right.position.y), 0.2)
			tween.tween_property(UI.instance.ui_tool_carousel.tool_right.material, "shader_parameter/modulate", Color(0.0, 0.0, 0.0, 0.0), 0.2)
			tween.tween_property(UI.instance.ui_tool_carousel.tool_right.material, "shader_parameter/coeff", 0.8, 0.2)
			tween.tween_callback(func(): UI.instance.ui_tool_carousel.tool_right.position.x = 1121.0).set_delay(0.2)
			tween.tween_callback(func(): (UI.instance.ui_tool_carousel.tool_right.material as ShaderMaterial).set_shader_parameter("modulate", UI.instance.ui_tool_carousel.semi_transparent_color)).set_delay(0.2)
			tween.tween_callback(func(): (UI.instance.ui_tool_carousel.tool_right.material as ShaderMaterial).set_shader_parameter("coeff", 0.2)).set_delay(0.2)

			var next_id : int = wrapi(current_tool_id - 1, 0, len(tools))

			tween.tween_callback(func(): UI.instance.ui_tool_carousel.tool_right.texture = tools[wrapi(current_tool_id + 1, 0, len(tools))].hud_icon).set_delay(0.2)

			tween.tween_property(UI.instance.ui_tool_carousel.tool_left_animated, "position", Vector2(945.0, UI.instance.ui_tool_carousel.tool_right_animated.position.y), 0.2)
			tween.tween_property(UI.instance.ui_tool_carousel.tool_left_animated.material, "shader_parameter/modulate", UI.instance.ui_tool_carousel.semi_transparent_color, 0.2)
			tween.tween_property(UI.instance.ui_tool_carousel.tool_left_animated.material, "shader_parameter/coeff", 0.2, 0.2)
			tween.tween_callback(func(): UI.instance.ui_tool_carousel.tool_left_animated.position.x = 857.0).set_delay(0.2)
			tween.tween_callback(func(): (UI.instance.ui_tool_carousel.tool_left_animated.material as ShaderMaterial).set_shader_parameter("modulate", Color(0.0, 0.0, 0.0, 0.0))).set_delay(0.2)
			tween.tween_callback(func(): (UI.instance.ui_tool_carousel.tool_left_animated.material as ShaderMaterial).set_shader_parameter("coeff", 0.8)).set_delay(0.2)

			tween.tween_property(UI.instance.ui_tool_carousel.arrow_left, "position", Vector2(934.0 - 8.0, UI.instance.ui_tool_carousel.arrow_left.position.y), 0.1)
			tween.tween_property(UI.instance.ui_tool_carousel.arrow_left, "position", Vector2(934.0, UI.instance.ui_tool_carousel.arrow_left.position.y), 0.1).set_delay(0.1)

			UI.instance.ui_tool_carousel.tool_left_animated.texture = tools[next_id].hud_icon

			return
		if (Input.is_action_just_pressed("player_action_previous_tool")):
			_previous_tool()

			UI.instance.ui_tool_carousel.audio_accent_1.play()

			var tween = create_tween()
			tween.set_parallel(true)

			tween.tween_property(UI.instance.ui_tool_carousel.tool_center, "position", Vector2(945.0, UI.instance.ui_tool_carousel.tool_center.position.y), 0.2)
			tween.tween_property(UI.instance.ui_tool_carousel.tool_center.material, "shader_parameter/modulate", UI.instance.ui_tool_carousel.semi_transparent_color, 0.2)
			tween.tween_property(UI.instance.ui_tool_carousel.tool_center.material, "shader_parameter/coeff", 0.2, 0.2)
			tween.tween_callback(func(): UI.instance.ui_tool_carousel.tool_center.position.x = 1033.0).set_delay(0.2)
			tween.tween_callback(func(): (UI.instance.ui_tool_carousel.tool_center.material as ShaderMaterial).set_shader_parameter("modulate", Color(1.0, 1.0, 1.0, 1.0))).set_delay(0.2)
			tween.tween_callback(func(): (UI.instance.ui_tool_carousel.tool_center.material as ShaderMaterial).set_shader_parameter("coeff", 0.00)).set_delay(0.2)

			tween.tween_callback(func(): UI.instance.ui_tool_carousel.tool_center.texture = current_tool.hud_icon).set_delay(0.2)

			tween.tween_property(UI.instance.ui_tool_carousel.tool_left, "position", Vector2(857.0, UI.instance.ui_tool_carousel.tool_left.position.y), 0.2)
			tween.tween_property(UI.instance.ui_tool_carousel.tool_left.material, "shader_parameter/modulate", Color(0.0, 0.0, 0.0, 0.0), 0.2)
			tween.tween_property(UI.instance.ui_tool_carousel.tool_left.material, "shader_parameter/coeff", 0.8, 0.2)
			tween.tween_callback(func(): UI.instance.ui_tool_carousel.tool_left.position.x = 945.0).set_delay(0.2)
			tween.tween_callback(func(): (UI.instance.ui_tool_carousel.tool_left.material as ShaderMaterial).set_shader_parameter("modulate", UI.instance.ui_tool_carousel.semi_transparent_color)).set_delay(0.2)
			tween.tween_callback(func(): (UI.instance.ui_tool_carousel.tool_left.material as ShaderMaterial).set_shader_parameter("coeff", 0.2)).set_delay(0.2)

			tween.tween_callback(func(): UI.instance.ui_tool_carousel.tool_left.texture = tools[current_tool_id - 1].hud_icon).set_delay(0.2)

			tween.tween_property(UI.instance.ui_tool_carousel.tool_right, "position", Vector2(1033.0, UI.instance.ui_tool_carousel.tool_right.position.y), 0.2)
			tween.tween_property(UI.instance.ui_tool_carousel.tool_right.material, "shader_parameter/modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)
			tween.tween_property(UI.instance.ui_tool_carousel.tool_right.material, "shader_parameter/coeff", 0.0, 0.2)
			tween.tween_callback(func(): UI.instance.ui_tool_carousel.tool_right.position.x = 1121.0).set_delay(0.2)
			tween.tween_callback(func(): (UI.instance.ui_tool_carousel.tool_right.material as ShaderMaterial).set_shader_parameter("modulate", UI.instance.ui_tool_carousel.semi_transparent_color)).set_delay(0.2)
			tween.tween_callback(func(): (UI.instance.ui_tool_carousel.tool_right.material as ShaderMaterial).set_shader_parameter("coeff", 0.2)).set_delay(0.2)

			var next_id : int = wrapi(current_tool_id + 1, 0, len(tools))

			tween.tween_callback(func(): UI.instance.ui_tool_carousel.tool_right.texture = tools[wrapi(current_tool_id + 1, 0, len(tools))].hud_icon).set_delay(0.2)

			tween.tween_property(UI.instance.ui_tool_carousel.tool_right_animated, "position", Vector2(1121.0, UI.instance.ui_tool_carousel.tool_right_animated.position.y), 0.2)
			tween.tween_property(UI.instance.ui_tool_carousel.tool_right_animated.material, "shader_parameter/modulate", UI.instance.ui_tool_carousel.semi_transparent_color, 0.2)
			tween.tween_property(UI.instance.ui_tool_carousel.tool_right_animated.material, "shader_parameter/coeff", 0.2, 0.2)
			tween.tween_callback(func(): UI.instance.ui_tool_carousel.tool_right_animated.position.x = 1209.0).set_delay(0.2)
			tween.tween_callback(func(): (UI.instance.ui_tool_carousel.tool_right_animated.material as ShaderMaterial).set_shader_parameter("modulate", Color(0.0, 0.0, 0.0, 0.0))).set_delay(0.2)
			tween.tween_callback(func(): (UI.instance.ui_tool_carousel.tool_right_animated.material as ShaderMaterial).set_shader_parameter("coeff", 0.8)).set_delay(0.2)

			tween.tween_property(UI.instance.ui_tool_carousel.arrow_right, "position", Vector2(1242.0 + 8.0, UI.instance.ui_tool_carousel.arrow_right.position.y), 0.1)
			tween.tween_property(UI.instance.ui_tool_carousel.arrow_right, "position", Vector2(1242.0, UI.instance.ui_tool_carousel.arrow_right.position.y), 0.1).set_delay(0.1)

			UI.instance.ui_tool_carousel.tool_right_animated.texture = tools[next_id].hud_icon

			return

func _previous_tool():
	current_tool_id += 1

	if (current_tool_id >= len(tools)):
		current_tool_id = 0

	_update_tool()

func _next_tool():
	current_tool_id -= 1

	if (current_tool_id < 0):
		current_tool_id = len(tools) - 1

	_update_tool()

func _set_tool(id : int):
	current_tool_id = id

	_update_tool()

func _update_tool():
	if (!swap_cooldown_timer.is_stopped()):
		return

	swap_cooldown_timer.start(swap_cooldown)

	current_tool._unequip() # unequip the previous tool

	current_tool = tools[current_tool_id]
	current_tool._equip() # equip the new one

func _get_camera() -> CameraTool:
	for node in tools:
		if node is CameraTool:
			return node as CameraTool

	return null