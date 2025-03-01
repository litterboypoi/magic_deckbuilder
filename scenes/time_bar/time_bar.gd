class_name TimeBar
extends Control

const WIDTH_PER_UNIT: int = 30

@onready var need_progress_bar: TextureProgressBar = $NeedProgressBar
@onready var actual_progress_bar: TextureProgressBar = $ActualProgressBar

var test_current = 0

func _process(delta: float) -> void:
	test_current += delta * 4
	set_time_bar(test_current, 4.5)


func set_time_bar(current: float, need: float):
	current = clamp(current, 0, need)
	need_progress_bar.size = Vector2(ceil(need) * WIDTH_PER_UNIT, 16)
	actual_progress_bar.size = Vector2(ceil(need) * WIDTH_PER_UNIT, 16)
	need_progress_bar.value = (need / ceil(need)) * 100
	actual_progress_bar.value = (current / ceil(need)) * 100
