class_name UIProgress extends Control

@export var label : Label = null

var leaf_populator : LeafPopulator = null

var current_value : float = 0

func _process(delta) -> void:
	if (leaf_populator):
		current_value = leaf_populator.getLeafCleaningHandler().getProgress()

	label.text = "Progress: " + str(round(current_value * 100)) + "%"