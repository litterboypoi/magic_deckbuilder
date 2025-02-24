class_name ActionProgress
extends HBoxContainer

#
#func _ready() -> void:
	#update_progress(1, 3)


func update_progress(current: int, max_turn: int):
	for child in get_children():
		remove_child(child)
	
	if max_turn == 0:
		hide()
		return
	
	var safe_current = clampi(current, 0, max_turn)
	var the_rest = max_turn - safe_current
	
	for i in range(safe_current):
		add_child(_progress_item(true))
	
	for i in range(the_rest):
		add_child(_progress_item(false))
	
	show()
	


func _progress_item(light: bool):
	var item = ColorRect.new()
	item.custom_minimum_size = Vector2(4,4)
	if light:
		item.color = Color(0.708, 0.455, 0.238)
	else:
		item.color = Color(0.176, 0.176, 0.176)
	return item
