class_name LeafCleaningHandler extends Node

@export var cleaning_origin : Node3D = null

var last_origin_position : Vector3 = Vector3() # in global coordinates

signal on_origin_position_update

func _ready():
	last_origin_position = cleaning_origin.global_position

func _physics_process(delta):
	var last_origin_position_2d : Vector2 = Vector2(last_origin_position.x, last_origin_position.z)
	var cleaning_origin_position_2d : Vector2 = Vector2(cleaning_origin.global_position.x, cleaning_origin.global_position.z)

	if (last_origin_position_2d.distance_to(cleaning_origin_position_2d) > 0.1):
		on_origin_position_update.emit(cleaning_origin.global_position)
		last_origin_position = cleaning_origin.global_position
