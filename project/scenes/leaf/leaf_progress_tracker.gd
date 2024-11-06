class_name LeafProgressTracker extends Node

@export var leeway : int = 150

var cleaning_handler : LeafCleaningHandler

var is_completed : bool = false

var last_leaf_count : int = 0

signal on_completion

func _physics_process(delta):
	if (!cleaning_handler):
		return

	var target = max(cleaning_handler.getInstanceCount() - leeway, 1)
	var progress : float = float(cleaning_handler.getCleanedInstanceCount()) / float(target)

	if (!is_completed and progress >= 1.0):
		is_completed = true
		on_completion.emit()
		cleaning_handler.ClearAllLeaves()
		prints(progress)

	if (UI.instance):
		UI.instance.progress.current_value = progress

func _on_leaves_cleaned(amount : int):
	CashManager._reward_leaf_cleaning(amount)