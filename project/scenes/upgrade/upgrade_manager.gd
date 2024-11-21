extends Node

@export var inventory : Array[Upgrade] = []

@export var current_boots : MoveSpeedUpgrade = null:
    set(value):
        current_boots = value
        on_boots_update.emit()

signal on_broom_update
signal on_boots_update

func _grant_item(item : Upgrade):
    if (!item):
        return

    if (item.one_time_purchase and inventory.has(item)):
        return

    inventory.append(item)

    if (item is BroomUpgrade):
        on_broom_update.emit(item as BroomUpgrade)

func _set_current_item(item : Upgrade):
    if (item is MoveSpeedUpgrade):
        current_boots = item