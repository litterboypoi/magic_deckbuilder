class_name ExhaustSelectedEffect
extends Effect

var amount: int = 1
var optional: bool = false


func execute(targets: Array[Node]) -> void:
	if targets.is_empty():
		return

	var player_handler := targets[0].get_tree().get_first_node_in_group("player_handler") as PlayerHandler
	
	if not player_handler:
		return
	
	player_handler.select_exhaust_cards(amount, optional)
