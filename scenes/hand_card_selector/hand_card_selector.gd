extends Control

signal card_selected(cards: Array[CardUI])

@export var hand: Hand

@onready var select_reason: Label = $SelectReason
@onready var cards: HBoxContainer = $Cards
@onready var button: Button = $Button

var select_count: int = 0
var is_select_optional: bool = false


func _ready() -> void:
	Events.select_hand_requested.connect(show_select)


func show_select(_select_count: int, reason: String, select_optional: bool):
	select_reason.text = reason
	select_count = _select_count
	is_select_optional = select_optional
	button.disabled = not is_confirm_button_enable()
	visible = true
	Events.battle_ui_mask_show_requested.emit()
	Events.hand_card_selected.connect(_on_card_clicked)


func confirm_select():
	var selected_cards: Array[CardUI] = []
	selected_cards.assign(cards.get_children())
	Events.hand_cards_select_confirmed.emit(selected_cards)
	
	Events.hand_card_selected.disconnect(_on_card_clicked)
	visible = false
	Events.battle_ui_mask_hide_requested.emit()


func _on_card_clicked(card_ui: CardUI):
	if cards.get_children().has(card_ui):
		deselect(card_ui)
	else:
		select(card_ui)

func select(card_ui: CardUI):
	if cards.get_child_count() < select_count:
		hand.remove_child(card_ui)
		cards.add_child(card_ui)

func deselect(card_ui: CardUI):
	cards.remove_child(card_ui)
	hand.add_child(card_ui)


func is_confirm_button_enable() -> bool:
	# 可选
	if is_select_optional:
		return true
	# 选完了
	elif cards.get_child_count() == select_count:
		return true
	# 剩余的手牌都选完了
	elif cards.get_child_count() == hand.get_child_count():
		return true
	else:
		return false


func _on_cards_child_order_changed() -> void:
	if visible:
		button.disabled = not is_confirm_button_enable()


func _on_button_pressed() -> void:
	confirm_select()
	
