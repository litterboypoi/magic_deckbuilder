class_name ActionManager
extends Node

class ActionStackItem:
	var action: Callable
	var done: bool = false
	var promise: Promise

	func _init(_action: Callable):
		self.action = _action
		self.done = false
		self.promise = Promise.new()

var action_stack = []
var current_action: ActionStackItem

func push_action(action: Callable) -> Promise:
	var action_item = ActionStackItem.new(action)
	action_stack.push_back(action_item)
	if not current_action:
		_process_stack()
	return action_item.promise


func _process_stack():
	if action_stack.size() == 0:
		current_action = null
		return
	current_action = action_stack.back()
	if current_action.done:
		current_action.promise.resolve()
		action_stack.pop_back()
		_process_stack()
		return
	else:
		var action_promise = current_action.action.call()
		assert(action_promise is Promise, "Action must return a Promise")
		await action_promise.async_awaiter()
		current_action.done = true
		if current_action == action_stack.back():
			current_action.promise.resolve()
			action_stack.pop_back()
		_process_stack()
