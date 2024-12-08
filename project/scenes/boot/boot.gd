extends Control

func _ready():
    get_node("AnimationPlayer").play("default")

func _on_boot_finish() -> void:
    get_tree().change_scene_to_file("res://scenes/main/main.tscn")