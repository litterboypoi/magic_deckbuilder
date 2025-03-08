class_name StatusUI
extends Control

@export var status: Status : set = set_status

@onready var icon: TextureRect = $Icon
@onready var stacks: Label = $Stacks
@onready var duration_progress: TextureProgressBar = $DurationProgress


func set_status(new_status: Status) -> void:
	if not is_node_ready():
		await ready
	
	status = new_status
	icon.texture = status.icon
	# 这么做动态添加status_ui的时候，布局不会乱
	custom_minimum_size = icon.size
	if stacks.visible:
		custom_minimum_size = stacks.size + stacks.position
	
	if not status.status_changed.is_connected(_on_status_changed):
		status.status_changed.connect(_on_status_changed)
	
	if not status.status_destory_requested.is_connected(_on_status_destory_requested):
		status.status_destory_requested.connect(_on_status_destory_requested)
	
	if status.can_expire and not TimeSystem.tick.is_connected(_tick):
		TimeSystem.tick.connect(_tick)
	
	_on_status_changed()


func _on_status_changed() -> void:
	if not status:
		return

	stacks.visible = status.stacks > 0
	stacks.text = str(status.stacks)

	if status.can_expire and status.duration > 0:
		var progress = (status.countdown / status.duration) * 100
		var visual_progress = 100 - progress
		duration_progress.value = visual_progress
		duration_progress.visible = true
	else:
		duration_progress.visible = false


func _tick(delta: float):
	status.countdown += delta
	if status.countdown >= status.duration:
		status.duration_countdown_end()


# 合适销毁由status自身把控
func _on_status_destory_requested():
	queue_free()
