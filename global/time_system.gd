extends Node

signal time_scale_changed(time_scale: float)
signal tick(delta: float)


var time_scale: float = 1 : set = _set_time_scale
var is_time_flow := false
var time: float = 0

var default_time_scale: float = 0
var requested_time: float = 0
var time_scale_controled_manual = false


func _process(delta: float) -> void:
	if is_time_flow:
		tick.emit(delta * time_scale)


func _set_time_scale(val):
	time_scale = val
	time_scale_changed.emit(time_scale)


func time_flow():
	is_time_flow = true


func time_frozen():
	is_time_flow = false







func request_time(t: float):
	requested_time = max(t, requested_time)
