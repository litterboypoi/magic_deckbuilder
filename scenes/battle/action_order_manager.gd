# 处理同时触发的行动的顺序
class_name ActionOrderManager
extends Node

var is_handle_actions_called_this_frame: bool = false
var order_queue: Array[ActionOrder] = []
var current_order: ActionOrder


func _ready() -> void:
	Events.action_order_requested.connect(_on_action_order_requested)
	# Events.action_excute_requested.connect(_on_action_excute_requested)
	# Events.action_excute_completed.connect(_on_action_excute_completed)


func _on_action_order_requested(action: ActionOrder) -> void:
	order_queue.append(action)
	if not is_handle_actions_called_this_frame:
		is_handle_actions_called_this_frame = true
		call_deferred("handle_actions")


func _on_action_excute_requested(action: Action) -> void:
	order_queue.append(action)
	if not is_handle_actions_called_this_frame:
		is_handle_actions_called_this_frame = true
		call_deferred("handle_actions")


func handle_actions():
	order_actions()
	TimeSystem.time_frozen_b()
	handle_next_action()
	is_handle_actions_called_this_frame = false


func handle_next_action():
	if order_queue.size() == 0:
		TimeSystem.time_flow_b()
		return
	current_order = order_queue.pop_front()
	if is_instance_valid(current_order.action_owner):
		current_order.finished.connect(handle_next_action, ConnectFlags.CONNECT_ONE_SHOT)
		current_order.action.call(current_order)
	else:
		handle_next_action()
	


func order_actions():
	var ordered_actions: Array[ActionOrder] = []
	for action in order_queue:
		if action.action_owner is Player:
			ordered_actions.append(action)
	for action in order_queue:
		if action.action_owner is not Player:
			ordered_actions.append(action)
	order_queue = ordered_actions


func _on_action_excute_completed(action: Action) -> void:
	if action == current_order:
		handle_next_action()
