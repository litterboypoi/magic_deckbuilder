class_name StatusHandler
extends GridContainer

signal statuses_applied(type: LegalStatus.Type)

const STATUS_APPLY_INTERVAL := 0.25
const STATUS_UI = preload("res://scenes/status_handler/status_ui.tscn")

@export var status_owner: Node2D


func apply_statuses_by_type(type: LegalStatus.Type) -> void:
	statuses_applied.emit(type)
	pass


func add_status(status: Status) -> void:
	var stackable := status.stack_type != Status.StackType.NONE
	
	if not stackable:
		_create_status_ui(status)
		return
	else:
		if not has_status(status.id):
			_create_status_ui(status)
		
		if status.stack_type == Status.StackType.DURATION:
			get_status(status.id).duration += status.duration
		elif status.stack_type == Status.StackType.STACK:
			get_status(status.id).stacks += status.stacks
	


func _create_status_ui(status: Status) -> StatusUI:
	var new_status_ui := STATUS_UI.instantiate() as StatusUI
	add_child(new_status_ui)
	new_status_ui.status = status
	new_status_ui.status.initialize_status(status_owner)
	return new_status_ui


func has_status(id: String) -> bool:
	for status_ui: StatusUI in get_children():
		if status_ui.status.id == id:
			return true
			
	return false


func get_status(id: String) -> Status:
	for status_ui: StatusUI in get_children():
		if status_ui.status.id == id:
			return status_ui.status
	
	return null


func _get_all_statuses() -> Array[Status]:
	var statuses: Array[Status] = []
	for status_ui: StatusUI in get_children():
		statuses.append(status_ui.status)
		
	return statuses


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		Events.status_tooltip_requested.emit(_get_all_statuses())
