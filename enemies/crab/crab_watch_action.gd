class_name CrabWatchAction
extends AIAction

@export var attack_counter_action: AIAction

func enter() -> void:
	super.enter()
	Events.card_played.connect(on_card_played)


func exit() -> void:
	super.exit()
	Events.card_played.disconnect(on_card_played)


func do_excute(action_order: ActionOrder) -> void:
	var tween := action_owner.create_tween().set_trans(Tween.TRANS_QUINT)
	tween.tween_interval(0.25)
	
	tween.finished.connect(
		func():
			action_order.finished.emit()
			exit_requested.emit(self)
	)


func on_card_played(card: Card):
	if card.type == Card.Type.ATTACK:
		change_action_requested.emit(attack_counter_action, self)
