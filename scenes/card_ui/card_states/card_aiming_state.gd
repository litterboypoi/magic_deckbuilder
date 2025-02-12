extends CardState

const MOUSE_Y_SNAPBACK_THRESHOLD := 138


func enter() -> void:
	card_ui.targets.clear()
	var offset := Vector2(card_ui.parent.size.x / 2, -card_ui.size.y / 2)
	offset.x -= card_ui.size.x / 2
	card_ui.animate_to_position(card_ui.parent.global_position + offset, 0.2)
	card_ui.drop_point_detector.monitoring = false
	Events.card_aim_started.emit(card_ui)
	# TODO 弹幕的参数暂时debug写死
	Events.projectile_aim_started.emit(100, 50, 1)
	Events.aim_direction_changed.connect(_on_aim_direction_changed)


func exit() -> void:
	Events.card_aim_ended.emit(card_ui)
	Events.projectile_aim_ended.emit()
	Events.aim_direction_changed.disconnect(_on_aim_direction_changed)


func on_input(event: InputEvent) -> void:	
	var mouse_motion := event is InputEventMouseMotion
	var mouse_at_bottom := card_ui.get_global_mouse_position().y > MOUSE_Y_SNAPBACK_THRESHOLD
	
	if (mouse_motion and mouse_at_bottom) or event.is_action_pressed("right_mouse"):
		card_ui.targets.clear()
		transition_requested.emit(self, CardState.State.BASE)
	elif event.is_action_released("left_mouse") or event.is_action_pressed("left_mouse"):
		get_viewport().set_input_as_handled()
		transition_requested.emit(self, CardState.State.RELEASED)


func _on_aim_direction_changed(direction: Vector2):
	card_ui.aim_direction = direction
