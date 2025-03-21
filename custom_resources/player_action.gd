class_name PlayerAction
extends Action

var player: Player

func async_apply(_player: Node) -> void:
	player = _player
	assert(player is Player, "owner must be Player in PlayerAction")
	if player.stats.mana < cost:
		return
	player.stats.mana -= cost
	await _async_impl_apply()


func _action_precheck() -> bool:
	if not is_instance_valid(player) or player.is_queued_for_deletion():
		return false
	return true


func _async_get_targets(target: Target) -> Array[Node]:
	var location_manager = player.get_tree().get_first_node_in_group("location_manager") as LocationManager
	match target:
		Target.SELF:
			return [player]
		Target.RANGE:
			return location_manager.get_units_in_range(player.location + 1, player.location + 3)
		Target.SELECT:
			Events.enemy_aim_requested.emit()
			var aim_targets = await Events.enemy_aim_confirmed
			return aim_targets
		_:
			return []


func _async_impl_apply():
	pass


func _async_push_action(callable: Callable):
	await ActionManager.push_action(
		func ():
			if not is_instance_valid(player) or player.is_queued_for_deletion():
				return
			await callable.call()
	).async_awaiter()
