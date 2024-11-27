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

func _physics_process(delta) -> void:
	if (current_tool and !current_tool.allow_switch):
		return

	if (!player._block_input and !player.garbage_bag_handler.is_holding_a_bag):
		if (Input.is_action_just_pressed("player_action_next_tool")):
			_next_tool()
			return
		if (Input.is_action_just_pressed("player_action_previous_tool")):
			_previous_tool()
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