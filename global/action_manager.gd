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


func clear():
	action_stack.clear()
	current_action = null

# TODO 目前的排队规则还有缺陷，后续需要区分大action和小action，大aciton分开不同的栈，小action push到当前的栈中
# 感觉又不是很需要，任何需要用到所谓大aciton的地方我们都加上await就可以了
func push_action(action: Callable) -> Promise:
	var action_item = ActionStackItem.new(action)
	action_stack.push_back(action_item)
	if not current_action:
		_process_stack()
	return action_item.promise


func _process_stack():
	if action_stack.size() == 0:
		return
	current_action = action_stack.back()
	if current_action.done:
		current_action.promise.resolve()
		action_stack.pop_back()
		current_action = null
		_process_stack()
		return
	else:
		var action_promise = await current_action.action.call()
		if action_promise is Promise:
			await action_promise.async_awaiter()
		current_action.done = true
		if current_action == action_stack.back():
			current_action.promise.resolve()
			action_stack.pop_back()
		current_action = null
		_process_stack()
