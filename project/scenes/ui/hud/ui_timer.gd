class_name UITimer extends Control

@export var label : Label = null
@export var progress_bar : TextureProgressBar

@export var grade : Grade = null

func _process(delta):
    if (!Game.game_instance):
        return

    label.text = Game.game_instance.ranking_manager.get_formatted_time_elapsed()

    var rank = Game.game_instance.ranking_manager.get_current_rank()

    grade.grade = rank

    match rank:
        RankingManager.Rank.S:
            progress_bar.min_value = -Game.game_instance.ranking_manager.level.s_rank_target_time
            progress_bar.max_value = 0.0
        RankingManager.Rank.A:
            progress_bar.min_value = -Game.game_instance.ranking_manager.level.a_rank_target_time
            progress_bar.max_value = -Game.game_instance.ranking_manager.level.s_rank_target_time
        RankingManager.Rank.B:
            progress_bar.min_value = -Game.game_instance.ranking_manager.level.b_rank_target_time
            progress_bar.max_value = -Game.game_instance.ranking_manager.level.a_rank_target_time
        RankingManager.Rank.C:
            progress_bar.min_value = -Game.game_instance.ranking_manager.level.c_rank_target_time
            progress_bar.max_value = -Game.game_instance.ranking_manager.level.b_rank_target_time
        RankingManager.Rank.D:
            progress_bar.min_value = 0.0
            progress_bar.max_value = 1.0

    progress_bar.value = -Game.game_instance.ranking_manager.time_elapsed