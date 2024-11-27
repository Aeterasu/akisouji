class_name UITimer extends Control

@export var label : Label = null
@export var progress_bar : TextureProgressBar

func _process(delta):
    if (!Game.game_instance):
        return

    label.text = Game.game_instance.ranking_manager.get_formatted_time_elapsed()

    progress_bar.min_value = -Game.game_instance.ranking_manager.level.s_rank_target_time
    progress_bar.max_value = 0.0
    progress_bar.value = -Game.game_instance.ranking_manager.time_elapsed