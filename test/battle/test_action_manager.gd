extends GutTest

var action_manager: ActionManager

func before_each():
	action_manager = ActionManager.new()


func test_should_resolve_when_no_chain_action():
	var out_promise = action_manager.push_action(
		func():
			var promise = Promise.new()
			PromiseTestHelpers.resolve_after_time(self, promise)
			return promise
	)
	await out_promise.async_awaiter()
	assert_eq(out_promise.is_resolved(), true, "out promise should be resolved")


# CONFUSABLE_CAPTURE_REASSIGNMENT
# Local variables are captured by value once, when the lambda is created. So they won't be updated in the lambda if reassigned in the outer function
# 匿名函数不会修改外部函数的值类型变量
var action_order_squence = ""
func test_chain_action_order():
	action_order_squence = ""
	var out_promise = action_manager.push_action(
		func():
			var promise = Promise.new()
			promise.resolve()
			self.action_order_squence += "1"
			action_manager.push_action(
				func():
					var inner_promise = Promise.new()
					inner_promise.resolve()
					self.action_order_squence += "2"
					return inner_promise
			)
			return promise
	)
	await out_promise.async_awaiter()
	self.action_order_squence += "3"
	assert_eq(action_order_squence, "123", " action order  should be 123")
	


func test_complex_chain_action_order():
	action_order_squence = ""
	var out_promise = action_manager.push_action(
		func():
			var promise = Promise.new()
			promise.resolve()
			self.action_order_squence += "1"
			action_manager.push_action(
				func():
					var inner_promise = Promise.new()
					PromiseTestHelpers.resolve_after_time(self, inner_promise)
					self.action_order_squence += "2"
					return inner_promise
			)
			action_manager.push_action(
				func():
					var inner_promise = Promise.new()
					inner_promise.resolve()
					self.action_order_squence += "3"
					return inner_promise
			)
			return promise
	)
	await out_promise.async_awaiter()
	self.action_order_squence += "4"
	assert_eq(action_order_squence, "1324", " action order  should be 1324")
