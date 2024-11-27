class_name ShopSidepanel extends Control

@export var icon : TextureRect = null

@export var default_panel : Control = null
@export var motto_label : Label = null

@export var in_category_panel : Control = null
@export var shop_entry_description_label : RichTextLabel = null

var current_shop_entry_upgrade : Upgrade = null

func _process(delta):
    if (current_shop_entry_upgrade):
        shop_entry_description_label.text = "[center][font_size=36]" + tr(current_shop_entry_upgrade.name_key) + "[/font_size][/center]\n\n[center][font_size=24]" + tr(current_shop_entry_upgrade.description_key) + "[/font_size][/center]"
    #else:
        #shop_entry_description_label.hide()