class_name SpreadGroup extends Node

func _ready() -> void:
	var parent = get_parent()
	var groups = parent.get_groups()

	for node in parent.get_children():
		for group in groups:
			node.add_to_group(group)
	
	self.queue_free()