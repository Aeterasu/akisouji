class_name UI extends Control

@export var progress : UIProgress = null

@export var ui_timer : UITimer = null

@export var ui_garbage_bag_popup : UIGarbageBagPopup = null

@export var ui_interaction_tooltip : UIInteractionTooltip = null

@export var ui_tool_carousel : UIToolCarousel = null

static var instance : UI

func _ready():
	if (is_instance_valid(instance)):
		self.queue_free()
	else:
		instance = self

func _hide_ui_for_time(duration : float = 0.1) -> void:
	visible = false

	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = duration
	timer.one_shot = true
	timer.timeout.connect(func(): visible = true)
	timer.call_deferred("start")