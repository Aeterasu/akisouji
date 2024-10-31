extends Node

@export var inventory : Array[Upgrade] = []

@export var current_broom : BroomUpgrade = null

@export var current_boots : MoveSpeedUpgrade = null:
    set(value):
        current_boots = value
        on_boots_update.emit()

signal on_broom_update
signal on_boots_update

func _grant_item(item : Upgrade):
    if (!item):
        return

    inventory.append(item)

func _set_current_item(item : Upgrade):
    if (item is MoveSpeedUpgrade):
        current_boots = item
    elif (item is BroomUpgrade):
        current_broom = item