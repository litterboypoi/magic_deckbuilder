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

var is_rest_this_turn: bool = false
var is_rest_pre_turn: bool = false
var is_battle_start_turn: bool = false

var playing_cost_trun_card: CardUI
var acc_turn_of_playing_card: int = 0


func _ready() -> void:
	Events.card_played.connect(_on_card_played)
	Events.player_hand_drawn.connect(_on_player_hand_drawn)
	Events.cost_turn_card_released.connect(_on_cost_turn_card_released)
	Events.player_hand_discarded.connect(_on_player_hand_discarded)


func start_battle(char_stats: CharacterStats) -> void:
	is_battle_start_turn = true
	character = char_stats
	character.draw_pile = character.deck.custom_duplicate()
	character.draw_pile.shuffle()
	character.discard = CardPile.new()
	relics.relics_activated.connect(_on_relics_activated)
	player.status_handler.statuses_applied.connect(_on_statuses_applied)
	start_turn()


func start_turn() -> void:
	
	is_rest_pre_turn = is_rest_this_turn
	is_rest_this_turn = false
	if is_rest_pre_turn:
		character.reset_mana()
	
	Events.update_enemy_action_requested.emit()
	
	relics.activate_relics_by_type(Relic.Type.START_OF_TURN)


func end_turn() -> void:
	# 到这一步也不能变更敌人action了。
	Events.player_cant_action.emit()
	is_battle_start_turn = false
	hand.disable_hand()
	relics.activate_relics_by_type(Relic.Type.END_OF_TURN)


func rest() -> void:
	is_rest_this_turn = true
	end_turn()


func do_start_turn_ready():
	if playing_cost_trun_card:
		move_on_playing_card()
	else:
		# enable hand, enable rest_button
		hand.enable_hand()
		Events.player_action_enable_requested.emit()


func do_end_turn_will_done():
	if is_rest_this_turn:
		discard_cards()
	else:
		Events.enemy_turn_start_requested.emit()


func move_on_playing_card():
	# 到这一步就不能变更敌人action了。
	Events.player_cant_action.emit()
	acc_turn_of_playing_card +=1
	if acc_turn_of_playing_card == playing_cost_trun_card.card.cost_turn:
		acc_turn_of_playing_card = 0
		playing_cost_trun_card.play()
		playing_cost_trun_card = null
	end_turn()


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
	# 打出攻击牌时清空防御
	if card.type == Card.Type.ATTACK:
		character.block = 0
	if card.exhausts or card.type == Card.Type.POWER:
		return
	
	character.discard.add_card(card)


func _on_player_hand_drawn() -> void:
	do_start_turn_ready()


func _on_statuses_applied(type: Status.Type) -> void:
	match type:
		Status.Type.START_OF_TURN:
			if is_rest_pre_turn or is_battle_start_turn:
				draw_cards(character.cards_per_turn, true)
			else:
				do_start_turn_ready()
		Status.Type.END_OF_TURN:
			do_end_turn_will_done()


func _on_relics_activated(type: Relic.Type) -> void:
	match type:
		Relic.Type.START_OF_TURN:
			player.status_handler.apply_statuses_by_type(Status.Type.START_OF_TURN)
		Relic.Type.END_OF_TURN:
			player.status_handler.apply_statuses_by_type(Status.Type.END_OF_TURN)


func _on_cost_turn_card_released(card_ui: CardUI) -> void:
	playing_cost_trun_card = card_ui
	move_on_playing_card()


func _on_player_hand_discarded() -> void:
	Events.enemy_turn_start_requested.emit()
