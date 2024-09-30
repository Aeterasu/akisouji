class_name GravityComponent extends Node

@export var gravity : float = 9.8

var current_velocity : float = 0.0

func _ready():
	pass

func _physics_process(delta):
	current_velocity -= gravity * delta;

func hop(strength : float):
	if (strength < 0.0):
		strength = 0.0

	current_velocity = strength