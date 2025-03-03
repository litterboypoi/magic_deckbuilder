class_name TimeBar
extends Control

const WIDTH_PER_UNIT: int = 30

@onready var need_progress_bar: TextureProgressBar = $NeedProgressBar
@onready var actual_progress_bar: TextureProgressBar = $ActualProgressBar
@onready var spliters: Control = $Spliters

const TIME_BAR_SPLITER = preload("res://scenes/time_bar/time_bar_spliter.tscn")

var pre_need = 0
var anchor: Vector2

#var test_current = 0
#
#func _process(delta: float) -> void:
	#test_current += delta * 4
	#set_time_bar(test_current, 7.5)


func _ready() -> void:
	anchor = position + Vector2(size.x / 2, 0)


func set_time_bar(current: float, need: float):
	current = clamp(current, 0, need)
	var ceil_need = ceil(need)
	if need != pre_need:
		for n in spliters.get_children():
			n.queue_free()
		need_progress_bar.size = Vector2(ceil_need * WIDTH_PER_UNIT, 16)
		need_progress_bar.value = (need / ceil_need) * 100
		actual_progress_bar.size = Vector2(ceil_need * WIDTH_PER_UNIT, 16)
		
		position = anchor - Vector2(need_progress_bar.size.x / 2, 0)
		
		for i in range(max(0, ceil_need - 1)):
			var spliter = TIME_BAR_SPLITER.instantiate()
			spliters.add_child(spliter)
			spliter.position = Vector2((i + 1) * WIDTH_PER_UNIT - 1, 3)
	
	actual_progress_bar.value = (current / ceil(need)) * 100
