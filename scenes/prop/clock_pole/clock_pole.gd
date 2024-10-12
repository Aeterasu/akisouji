extends Node

@export var hour_hand : Node3D = null
@export var minute_hand : Node3D = null
@export var seconds_hand : Node3D = null

@export var hour_hand_back : Node3D = null
@export var minute_hand_back : Node3D = null
@export var seconds_hand_back : Node3D = null

var hour_angle : float = 0.0
var minute_angle : float = 0.0
var seconds_angle : float = 0.0

func _physics_process(delta):
	var lerp_weight = 6.0 * delta

	var time = Time.get_datetime_dict_from_system()

	hour_angle = lerp_angle(hour_angle, deg_to_rad((time["hour"] - 12.0) * 30.0), lerp_weight)
	minute_angle = lerp_angle(minute_angle, deg_to_rad((time["minute"] - 60.0) * 6.0), lerp_weight)
	seconds_angle = lerp_angle(seconds_angle, deg_to_rad((time["second"] - 60.0) * 6.0), lerp_weight)

	hour_hand.rotation = Vector3.FORWARD * hour_angle
	minute_hand.rotation = Vector3.FORWARD * minute_angle
	seconds_hand.rotation = Vector3.FORWARD * seconds_angle

	hour_hand_back.rotation = Vector3.BACK * hour_angle
	minute_hand_back.rotation = Vector3.BACK * minute_angle
	seconds_hand_back.rotation = Vector3.BACK * seconds_angle