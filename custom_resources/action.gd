class_name Action
extends Resource

signal exit_requested(action: Action)
signal change_action_requested(from: Action, to: Action)
signal excute_requested(action: Action)
signal excute_finished(action: Action)


@export var id: String
@export var need_time: float
@export_range(1, 10) var tick: int = 1
@export_multiline var card_text: String
@export var sound: AudioStream

# must be set when created
var action_owner: Node
var targets: Array[Node] = []
var modifiers: ModifierHandler

# change when during action
var charging_time: float = 0


func apply() -> Promise:
	return null


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
