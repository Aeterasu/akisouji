class_name UITimer extends Control

@export var label : Label = null
@export var timer_label : Label = null
@export var progress_bar : TextureProgressBar

@export var grade : Grade = null

func _process(delta):
    if (!Game.game_instance):
        return

    label.text = tr("COMPLETION_SCORE") + ": " + str(Game.game_instance.ranking_manager._get_current_score()).pad_zeros(9)

    var rank = Game.game_instance.ranking_manager.get_current_rank()

    timer_label.text = tr("TIME") + ": " + Game.game_instance.ranking_manager.get_formatted_time_elapsed()

    grade.grade = rank