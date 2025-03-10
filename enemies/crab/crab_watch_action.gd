class_name CrabWatchAction
extends AIAction

@export var attack_counter_action: AIAction

func enter() -> void:
	super.enter()
	Events.card_played.connect(on_card_played)


func exit() -> void:
	super.exit()
	Events.card_played.disconnect(on_card_played)


func do_excute(finish_callback: Callable) -> void:
	finish_callback.call()


func on_card_played(card: Card):
	if card.type == Card.Type.ATTACK:
		change_action_requested.emit(self, attack_counter_action)


func get_callables() -> Array[Callable]:
	
	var callable = Callable(self, "do_excute")

	return [callable]

