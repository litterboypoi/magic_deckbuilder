extends Node

signal time_scale_changed(time_scale: float)

var default_time_scale: float = 0
var time_scale: float = 0 : set = _set_time_scale
var time: float = 0
var requested_time: float = 0
var time_scale_controled_manual = false


func _process(delta: float) -> void:
	
	time += delta * time_scale
	
	if requested_time != 0:
		time_scale = 1
		requested_time = max(0, requested_time - delta)
	elif not time_scale_controled_manual:
		time_scale = 0

func _set_time_scale(val):
	time_scale = val
	time_scale_changed.emit(time_scale)


func request_time(t: float):
	requested_time = max(t, requested_time)

func time_flow():
	time_scale = 1
	time_scale_controled_manual = true
	
func time_frozen():
	time_scale = 0
	time_scale_controled_manual = false
