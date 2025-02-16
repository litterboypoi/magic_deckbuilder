extends CardState

const DRAG_MINIMUM_THRESHOLD := 0.05

var minimum_drag_time_elapsed := false


func enter() -> void:
	var ui_layer := get_tree().get_first_node_in_group("ui_layer")
	if ui_layer:
		card_ui.reparent(ui_layer)
	
	card_ui.card_visuals.panel.set("theme_override_styles/panel", card_ui.DRAG_STYLEBOX)
	Events.card_drag_started.emit(card_ui)
	
	minimum_drag_time_elapsed = false
	var threshold_timer := get_tree().create_timer(DRAG_MINIMUM_THRESHOLD, false)
	threshold_timer.timeout.connect(func(): minimum_drag_time_elapsed = true)


func exit() -> void:
	Events.card_drag_ended.emit(card_ui)


func on_input(event: InputEvent) -> void:
	var single_targeted := card_ui.card.is_single_targeted()
	var mouse_motion := event is InputEventMouseMotion
	var cancel = event.is_action_pressed("right_mouse")
	var confirm = event.is_action_released("left_mouse") or event.is_action_pressed("left_mouse")
	var attack_card := card_ui.card.is_attack_card()

	if not card_ui.is_spell_finished():
		if card_ui.targets.size() > 0:
			transition_requested.emit(self, CardState.State.SPELLING)
			return
		var spell_not_finished_cancel = event.is_action_pressed("right_mouse") or event.is_action_pressed("left_mouse") or event.is_action_released("left_mouse")
		if spell_not_finished_cancel:
			transition_requested.emit(self, CardState.State.BASE)
			return
	else:
		# 如果是攻击牌，切换至瞄准状态获取发射方向。
		if attack_card and card_ui.targets.size() > 0:
			transition_requested.emit(self, CardState.State.AIMING)
			return

		if single_targeted and mouse_motion and card_ui.targets.size() > 0:
			transition_requested.emit(self, CardState.State.AIMING)
			return
		
		var spell_finished_cancel = event.is_action_pressed("right_mouse")
		var spell_finished_confirm = event.is_action_released("left_mouse") or event.is_action_pressed("left_mouse")
		if spell_finished_cancel:
			transition_requested.emit(self, CardState.State.BASE)
		elif minimum_drag_time_elapsed and spell_finished_confirm and card_ui.is_spell_finished():
			get_viewport().set_input_as_handled()
			transition_requested.emit(self, CardState.State.RELEASED)
	
	if mouse_motion:
		card_ui.global_position = card_ui.get_global_mouse_position() - card_ui.pivot_offset
