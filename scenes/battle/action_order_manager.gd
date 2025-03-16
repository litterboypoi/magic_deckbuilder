# 处理同时触发的行动的顺序
class_name ActionOrderManager
extends Node

var is_handle_actions_called_this_frame: bool = false
var order_queue: Array[ActionOrder] = []
var current_order: ActionOrder

var is_wating_for_async_jobs_empty: bool = false


func _ready() -> void:
	Events.action_order_requested.connect(_on_action_order_requested)
	AsyncJobRecoder.jobs_emepty.connect(_on_async_jobs_empty)


func _on_action_order_requested(action: ActionOrder) -> void:
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
	handle_next_action_callable()
	

func handle_next_action_callable():
	if current_order.action_callables.size() == 0:
		Events.action_order_completed.emit(current_order)
		handle_next_action()
		return
	# FIXME is_instance_valid 不能判断一个实例是否刚被调用queue_free
	if is_instance_valid(current_order.action_owner) and not current_order.action_owner.is_queued_for_deletion():
		current_order.action_owner.tree_exited.connect(_on_doing_callable_owner_tree_exited)
		var callable = current_order.action_callables.pop_front()
		callable.call(Callable(self, "_on_callable_finished"))
	else:
		handle_next_action()


func handle_next_action_delay():
	var tween = Tween.new()
	tween.tween_interval(0.17)
	tween.tween_callback(handle_next_action)


func _on_doing_callable_owner_tree_exited() -> void:
	_on_callable_finished()


func _on_callable_finished() -> void:
	# 清除tree_exited的连接
	if is_instance_valid(current_order.action_owner) and current_order.action_owner.tree_exited.is_connected(_on_doing_callable_owner_tree_exited):
		current_order.action_owner.tree_exited.disconnect(_on_doing_callable_owner_tree_exited)
	# TODO 不仅要等callable完成还要等耗时的其他行为完成
	if AsyncJobRecoder.is_empty():
		handle_next_action_callable()
	else:
		is_wating_for_async_jobs_empty = true

func _on_async_jobs_empty() -> void:
	if is_wating_for_async_jobs_empty:
		is_wating_for_async_jobs_empty = false
		call_deferred("handle_next_action_callable")

func order_actions():
	var ordered_actions: Array[ActionOrder] = []
	for action in order_queue:
		if action.action_owner is Player:
			ordered_actions.append(action)
	for action in order_queue:
		if action.action_owner is not Player:
			ordered_actions.append(action)
	order_queue = ordered_actions
