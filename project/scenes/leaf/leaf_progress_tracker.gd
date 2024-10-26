class_name LeafProgressTracker extends Node

@export var leeway : float = 0.01

var cleaning_handler : LeafCleaningHandler

var is_completed : bool = false

var last_leaf_count : int = 0

signal on_completion

func _physics_process(delta):
	if (!cleaning_handler):
		return

	var progress : float = float(cleaning_handler.getCleanedInstanceCount()) / (float(cleaning_handler.getInstanceCount()) - float(cleaning_handler.getInstanceCount()) * leeway)

	if (!is_completed and progress >= 1.0):
		is_completed = true
		on_completion.emit()
		prints(progress)

	if (UI.instance):
		UI.instance.progress.current_value = progress

func _on_leaves_cleaned(amount : int):
	CashManager._reward_leaf_cleaning(amount)