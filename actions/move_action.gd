class_name MoveAction
extends PlayerAction

@export var distance: int = 1


func _async_impl_apply(promise: Promise, player: Player):
	var location_manager = player.get_tree().get_first_node_in_group("location_manager") as LocationManager
	
	location_manager.move_finished.connect(
		func():
			promise.resolve()
	, ConnectFlags.CONNECT_ONE_SHOT)
	
	location_manager.move_unit(player, distance)
