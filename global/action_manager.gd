extends Node

class ActionStackItem:
	var action: Callable
	var done: bool = false
	var promise: Promise

	func _init(_action: Callable):
		self.action = _action
		self.done = false
		self.promise = Promise.new()

var stack_queue = []
var action_stack
var current_action: ActionStackItem


func _process(_delta: float) -> void:
	if not action_stack:
		if stack_queue.size() == 0:
			return
		action_stack = stack_queue.pop_front()
		_process_stack()


func clear():
	action_stack = null
	current_action = null
	stack_queue.clear()

# TODO 目前的排队规则还有缺陷，后续需要区分大action和小action，大aciton分开不同的栈，小action push到当前的栈中
# 感觉又不是很需要，任何需要用到所谓大aciton的地方我们都加上await就可以了
# 不对await之后的语句是优于resolve之后的语句执行的
func push_action(action: Callable) -> Promise:
	var action_item = ActionStackItem.new(action)
	var new_stack = []
	new_stack.push_back(action_item)
	stack_queue.push_back(new_stack)
	return action_item.promise


func push_mico_action(action: Callable) -> Promise:
	var action_item = ActionStackItem.new(action)
	if action_stack:
		action_stack.push_back(action_item)
	else:
		var new_stack = []
		new_stack.push_back(action_item)
		stack_queue.push_back(new_stack)
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
			# resolve 之后会立即执行 await async_waiter 的代码
			# 而不是下一行 action_stack.pop_back()
			current_action.promise.resolve()
			action_stack.pop_back()
		current_action = null
		_process_stack()
