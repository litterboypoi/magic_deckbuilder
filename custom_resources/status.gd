class_name Status
extends Resource

signal status_changed
signal status_destory_requested

enum StackType {NONE, STACK, DURATION}

@export_group("Status Data")
@export var id: String
@export var stack_type: StackType
# 是否关注时间，can_expire = true 不代表stack_type = DURATION
@export var can_expire: bool
@export var duration: float : set = set_duration
@export var stacks: int : set = set_stacks

@export_group("Status Visuals")
@export var icon: Texture
@export_multiline var tooltip: String

var countdown: float = 0 : set = set_countdown


func initialize_status(_target: Node) -> void:
	pass


# 通常countdown_end之后有两种情况。1. 销毁 2. stack -1 然后重新计时
func duration_countdown_end() -> void:
	pass


func destory_status() -> void:
	status_destory_requested.emit()


func get_tooltip() -> String:
	return tooltip


func set_duration(new_duration: float) -> void:
	duration = new_duration
	status_changed.emit()


func set_stacks(new_stacks: int) -> void:
	stacks = new_stacks
	status_changed.emit()
	if stack_type == StackType.STACK and stacks == 0:
		destory_status()


func set_countdown(new_countdown: float) -> void:
	countdown = new_countdown
	status_changed.emit()
