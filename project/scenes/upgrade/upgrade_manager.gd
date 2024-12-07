extends Node

@export var inventory : Array[Upgrade] = []

@export var upgrade_database : Array[Upgrade] = []

@export var current_boots : MoveSpeedUpgrade = null:
    set(value):
        current_boots = value
        on_boots_update.emit()

var unlocked_array : Array[bool] = []

var new_brooms_unlocked : bool = false
var new_boots_unlocked : bool = false

signal on_broom_update
signal on_boots_update

func _ready() -> void:
    unlocked_array.resize(len(upgrade_database))

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

func _check_unlocks():
    if (!is_instance_valid(Game.game_instance)):
        return

    var show_notif : bool = false

    for upgrade in upgrade_database:
        var i = upgrade_database.find(upgrade)
        if (CashManager.cash >= upgrade.cost and not unlocked_array[i] and !(_is_upgrade_bought(i))):
            unlocked_array[i] = true
            show_notif = true

            if (upgrade is MoveSpeedUpgrade):
                new_boots_unlocked = true
            elif (upgrade is BroomUpgrade):
                new_brooms_unlocked = true

    if (show_notif):
        UI.instance.ui_new_upgrade_notification._animate()

func _is_upgrade_bought(id : int) -> bool:
    if (id > len(upgrade_database) - 1):
        return false

    return inventory.has(upgrade_database[id])

func _get_equipped_boots_id() -> int:
    var i = upgrade_database.find(current_boots)

    return max(i, 0)

func _grant_upgrade_by_id(id : int) -> void:
    if (id > len(upgrade_database) - 1):
        return

    inventory.append(upgrade_database[id])

func _set_equipped_boots_by_id(id : int) -> void:
    if (id > len(upgrade_database) - 1):
        return

    var u = upgrade_database[id]

    if (u is MoveSpeedUpgrade):
        current_boots = upgrade_database[id]