extends ColorRect

func _ready() -> void:
	Events.battle_ui_mask_show_requested.connect(_on_battle_ui_mask_show_requested)
	Events.battle_ui_mask_hide_requested.connect(_on_battle_ui_mask_hide_requested)


func _on_battle_ui_mask_show_requested():
	visible = true

func _on_battle_ui_mask_hide_requested():
	visible = false
