class_name Action
extends Resource


enum Target {SELF, RANGE, SELECT}

@export var id: String
@export_range(1, 10) var tick: int = 1
@export var cost = 0
@export_multiline var card_text: String
@export var sound: AudioStream

# must be set when created
var action_owner: Node
var targets: Array[Node] = []
var modifiers: ModifierHandler


func async_apply(player: Player) -> Promise:
	if not is_instance_valid(player) or player.is_queued_for_deletion():
		return null
	if player.stats.mana < cost:
		return null
	player.stats.mana -= cost
	var promise = Promise.new()
	await _async_impl_apply(promise)
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


func _async_impl_apply(promise: Promise):
	promise.resolve()


func get_default_tooltip() -> String:
	return card_text


func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return card_text


func enter() -> void:
	pass


func exit() -> void:
	pass


func excute() -> void:
	var action_order = ActionOrder.new()
	action_order.action_owner = action_owner
	action_order.action_callables = get_callables()
	Events.action_order_requested.emit(action_order)


func get_callables() -> Array[Callable]:
	return []
