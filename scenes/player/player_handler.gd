# Player turn order:
# 1. START_OF_TURN Relics 
# 2. START_OF_TURN Statuses
# 3. Draw Hand
# 4. End Turn 
# 5. END_OF_TURN Relics 
# 6. END_OF_TURN Statuses
# 7. Discard Hand
class_name PlayerHandler
extends Node

const HAND_DRAW_INTERVAL := 0.25
const HAND_DISCARD_INTERVAL := 0.25

@export var relics: RelicHandler
@export var player: Player
@export var hand: Hand

var character: CharacterStats

func _ready() -> void:
	Events.card_played.connect(_on_card_played)


func start_battle(char_stats: CharacterStats) -> void:
	character = char_stats
	character.draw_pile = character.deck.custom_duplicate()
	character.draw_pile.shuffle()
	character.discard = CardPile.new()
	relics.relics_activated.connect(_on_relics_activated)
	player.status_handler.statuses_applied.connect(_on_statuses_applied)


# 抽牌、设置新的行动顺序
func start_turn() -> void:
	character.block = 0
	character.reset_mana()
	player.action_group.clear()
	draw_cards(character.cards_per_turn, true)


func end_turn() -> void:
	hand.disable_hand()
	discard_cards()


func tick() -> void:
	var reach_action = player.action_group.get_reach_action()
	if reach_action:
		await ActionManager.push_action(reach_action.async_apply.bind(player)).async_awaiter()


func is_action_group_reach_end() -> bool:
	return player.action_group.tick_index == player.action_group.get_tick_length()


func draw_card() -> void:
	reshuffle_deck_from_discard()
	hand.add_card(character.draw_pile.draw_card())
	reshuffle_deck_from_discard()


func draw_cards(amount: int, is_start_of_turn_draw: bool = false) -> void:
	var tween := create_tween()
	for i in range(amount):
		tween.tween_callback(draw_card)
		tween.tween_interval(HAND_DRAW_INTERVAL)
	
	tween.finished.connect(
		func(): 
			hand.enable_hand()
			if is_start_of_turn_draw:
				Events.player_hand_drawn.emit()
	)


func discard_cards() -> void:
	if hand.get_child_count() == 0:
		Events.player_hand_discarded.emit()
		return

	var cards: Array[CardUI] = []
	cards.assign(hand.get_children())
	var tween = _impl_discard_cards(cards)
	
	tween.finished.connect(
		func():
			Events.player_hand_discarded.emit()
	)

func _impl_discard_cards(cards: Array[CardUI]) -> Tween:
	var tween := create_tween()
	for card_ui: CardUI in cards:
		tween.tween_callback(character.discard.add_card.bind(card_ui.card))
		tween.tween_callback(hand.discard_card.bind(card_ui))
		tween.tween_interval(HAND_DISCARD_INTERVAL)
	
	return tween


func select_discard_cards(amount: int, optional: bool) -> void:
	Events.select_hand_requested.emit(amount, "exhaust", optional)
	Events.hand_cards_select_confirmed.connect(
		_impl_discard_cards
		, ConnectFlags.CONNECT_ONE_SHOT
	)


func select_exhaust_cards(amount: int, optional: bool) -> void:
	Events.select_hand_requested.emit(amount, "exhaust", optional)
	Events.hand_cards_select_confirmed.connect(
		_on_exhaust_hand_cards_select_confirmed
		, ConnectFlags.CONNECT_ONE_SHOT
	)


func _on_exhaust_hand_cards_select_confirmed(cards: Array[CardUI]):
	for card in cards:
		card.queue_free()


func reshuffle_deck_from_discard() -> void:
	if not character.draw_pile.empty():
		return

	while not character.discard.empty():
		character.draw_pile.add_card(character.discard.draw_card())

	character.draw_pile.shuffle()


func _on_card_played(card: Card) -> void:
	# TODO 暂时写在这里
	player.action_group.append_action(card.action.duplicate())
	if card.exhausts or card.type == Card.Type.POWER:
		return
	
	character.discard.add_card(card)


func _on_statuses_applied(type: LegalStatus.Type) -> void:
	match type:
		LegalStatus.Type.START_OF_TURN:
			draw_cards(character.cards_per_turn, true)
		LegalStatus.Type.END_OF_TURN:
			discard_cards()


func _on_relics_activated(type: Relic.Type) -> void:
	match type:
		Relic.Type.START_OF_TURN:
			player.status_handler.apply_statuses_by_type(LegalStatus.Type.START_OF_TURN)
		Relic.Type.END_OF_TURN:
			player.status_handler.apply_statuses_by_type(LegalStatus.Type.END_OF_TURN)
