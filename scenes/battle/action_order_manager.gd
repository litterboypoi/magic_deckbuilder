# 处理同时触发的行动的顺序
class_name ActionOrderManager
extends Node

var is_time_flow_this_frame: bool = false
var is_handle_actions_called_this_frame: bool = false
var action_queue: Array[Action] = []
var current_action: Action


func _ready() -> void:
	Events.action_excute_requested.connect(_on_action_excute_requested)
	Events.action_excute_completed.connect(_on_action_excute_completed)


func _on_action_excute_requested(action: Action) -> void:
	action_queue.append(action)
	if not is_handle_actions_called_this_frame:
		is_handle_actions_called_this_frame = true
		call_deferred("handle_actions")


func handle_actions():
	is_time_flow_this_frame = TimeSystem.is_time_flow
	order_actions()
	TimeSystem.time_frozen()
	handle_next_action()
	is_handle_actions_called_this_frame = false


func handle_next_action():
	if action_queue.size() == 0:
		# all actions are finished
		# recover time flow if it was time flow
		if is_time_flow_this_frame:
			TimeSystem.time_flow()
		return
	current_action = action_queue.pop_front()
	Events.action_excute_permited.emit(current_action)


func order_actions():
	var ordered_actions: Array[Action] = []
	for action in action_queue:
		if action.action_owner is Player:
			ordered_actions.append(action)
	for action in action_queue:
		if action.action_owner is not Player:
			ordered_actions.append(action)
	action_queue = ordered_actions


func _on_action_excute_completed(action: Action) -> void:
	if action == current_action:
		handle_next_action()
