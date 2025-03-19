class_name PlayerAction
extends Action

func async_apply(player: Node) -> Promise:
	assert(player is Player, "owner must be Player in PlayerAction")
	if not is_instance_valid(player) or player.is_queued_for_deletion():
		return null
	if player.stats.mana < cost:
		return null
	player.stats.mana -= cost
	var promise = Promise.new()
	await _async_impl_apply(promise, player)
	return promise


func _async_get_targets(target: Target, tree: SceneTree) -> Array[Node]:
	var location_manager = tree.get_first_node_in_group("location_manager") as LocationManager
	var player = tree.get_first_node_in_group("player") as Player
	match target:
		Target.SELF:
			return [player]
		Target.RANGE:
			return location_manager.get_units_in_range(player.location + 1, player.location + 3)
		Target.SELECT:
			var select_promise = Promise.new()
			tree.create_timer(0.1).timeout.connect(
				func ():
					select_promise.resolve()
			)
			await select_promise.async_awaiter()
			return []
		_:
			return []


func _async_impl_apply(promise: Promise, _player: Player):
	promise.resolve()
