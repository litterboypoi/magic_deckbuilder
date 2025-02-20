extends CardState

const MOUSE_Y_SNAPBACK_THRESHOLD := 138
var mouse_over_card = false

func enter() -> void:
	Events.hand_cards_select_confirmed.connect(_on_hand_cards_select_confirmed)


func exit() -> void:
	Events.hand_cards_select_confirmed.disconnect(_on_hand_cards_select_confirmed)


func _on_hand_cards_select_confirmed(_cards: Array[CardUI]):
	transition_requested.emit(self, CardState.State.BASE)


func on_input(event: InputEvent) -> void:	
	if mouse_over_card and event.is_action_pressed("left_mouse"):
		Events.hand_card_selected.emit(card_ui)


func on_mouse_entered() -> void:
	mouse_over_card = true


func on_mouse_exited() -> void:
	mouse_over_card = false
	
