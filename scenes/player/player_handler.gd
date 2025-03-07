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

var current_action: Action
var is_resting: bool = false
var rest_time: float = 0


func _ready() -> void:
	Events.card_played.connect(_on_card_played)
	Events.action_excute_permited.connect(_on_action_excute_premited)


func _input(event: InputEvent) -> void:
	if event.is_action_released("rest"):
		rest()


func start_battle(char_stats: CharacterStats) -> void:
	character = char_stats
	character.draw_pile = character.deck.custom_duplicate()
	character.draw_pile.shuffle()
	character.discard = CardPile.new()
	relics.relics_activated.connect(_on_relics_activated)
	player.status_handler.statuses_applied.connect(_on_statuses_applied)
	start_turn()


func start_turn() -> void:
	character.block = 0
	character.reset_mana()
	relics.activate_relics_by_type(Relic.Type.START_OF_TURN)


func end_turn() -> void:
	hand.disable_hand()
	relics.activate_relics_by_type(Relic.Type.END_OF_TURN)


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


## new logic of real time
func start_action(new_action: Action):
	if is_resting:
		return
	if current_action:
		if new_action.need_time == 0:
			_exit_action(current_action)
			_enter_action(new_action)
		else:
			return
	else:
		_enter_action(new_action)
	

func _exit_action(action: Action):
	action.exit_requested.disconnect(_exit_action)
	action.exit()
	current_action = null
	# FIXME 我不仅仅应该在这ime_forzen
	TimeSystem.time_frozen()
	

func _enter_action(action: Action):
	current_action = action
	current_action.exit_requested.connect(_exit_action)
	current_action.excute_requested.connect(_on_excute_requested)
	current_action.excute_finished.connect(_on_excute_finished)
	current_action.enter()
	
	if current_action.need_time != 0:
		TimeSystem.time_flow()



func _on_excute_requested(action: Action):
	TimeSystem.time_frozen()
	Events.action_excute_requested.emit(action)
	# TODO player action 期间可能要做一些禁用操作，可能在这里也可能在action_order_manager中做


func _on_action_excute_premited(action: Action):
	if action == current_action:
		current_action.do_excute()


func _on_excute_finished(action: Action):
	Events.action_excute_completed.emit(action)



func rest():
	if current_action:
		return
	is_resting = true
	TimeSystem.tick.connect(_rest_tick)
	discard_cards()
	TimeSystem.time_flow()

func _exit_rest():
	if is_resting:
		is_resting = false
		rest_time = 0
		TimeSystem.time_frozen()
		TimeSystem.tick.disconnect(_rest_tick)
		draw_cards(character.cards_per_turn, true)


func _rest_tick(delta: float):
	var REST_TIME = 1
	var RECOVER_PER_SECOND: float = 3
	player.stats.mana += delta * RECOVER_PER_SECOND
	rest_time += delta
	if rest_time >= REST_TIME:
		_exit_rest()
