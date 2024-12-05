class_name LeafProgressTracker extends Node

@export var leeway : int = 150

var cleaning_handler : LeafCleaningHandler

var is_completed : bool = false

var last_leaf_count : int = 0
var cleaned_leaves_count : int = 0

signal on_completion

func _physics_process(delta):
	if (!cleaning_handler):
		return

	var target = max(cleaning_handler.getInstanceCount() - leeway, 1)
	var progress : float = float(cleaned_leaves_count) / float(target)

	#prints("progress: ", progress, "instance count: ", cleaning_handler.getInstanceCount(), ", target: ", target, ", cleaned count: ", cleaned_leaves_count)

	if (!is_completed and progress >= 1.0):
		is_completed = true
		on_completion.emit()
		cleaning_handler.ClearAllLeaves()
		#prints(progress)

	if (UI.instance and UI.instance.progress.current_value != progress):
		UI.instance.progress.current_value = progress

func _on_leaves_cleaned(amount : int):
	CashManager._reward_leaf_cleaning(amount)
	cleaned_leaves_count += amount