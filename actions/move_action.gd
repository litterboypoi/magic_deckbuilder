class_name MoveAction
extends Action

@export var distance: int = 1


func do_excute(finish_callback: Callable) -> void:
	var location_manager = action_owner.get_tree().get_first_node_in_group("location_manager") as LocationManager
	
	location_manager.move_finished.connect(
		func():
			finish_callback.call()
	, ConnectFlags.CONNECT_ONE_SHOT)
	
	location_manager.move_unit(action_owner, distance)


func get_callables() -> Array[Callable]:
	
	var callable = Callable(self, "do_excute")

	return [callable]
