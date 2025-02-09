extends Node

signal time_scale_changed(time_scale: float)

func request_time(time: float):
	time_scale_changed.emit(1)
	await get_tree().create_timer(time).timeout
	time_scale_changed.emit(0)
