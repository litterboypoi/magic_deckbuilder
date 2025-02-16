extends CardState

const MOUSE_Y_SNAPBACK_THRESHOLD := 138
var is_holding_left_mouse = true

func enter() -> void:
	TimeSystem.time_flow()
	card_ui.spell_finished.connect(_on_spell_finished)
	Events.card_drag_started.emit(card_ui)


func process(delta: float) -> void:
	card_ui.spell_card(delta)

func exit() -> void:
	TimeSystem.time_frozen()
	card_ui.spell_finished.disconnect(_on_spell_finished)
	Events.card_drag_ended.emit(card_ui)


func on_input(event: InputEvent) -> void:	
	var mouse_motion := event is InputEventMouseMotion
	var out_of_drop_area = card_ui.targets.size() == 0
	var cancel = (is_holding_left_mouse and event.is_action_released("left_mouse")) or event.is_action_pressed("right_mouse")
	
	# 进入这个状态用户还能点击鼠标左键，说明用户不是拖着鼠标左键打出卡牌的
	if event.is_action_pressed("left_mouse"):
		is_holding_left_mouse = false
	
	if out_of_drop_area:
		transition_requested.emit(self, CardState.State.DRAGGING)
	
	if cancel:
		transition_requested.emit(self, CardState.State.BASE)
	
	if mouse_motion:
		card_ui.global_position = card_ui.get_global_mouse_position() - card_ui.pivot_offset

func _on_spell_finished():
	transition_requested.emit(self, CardState.State.DRAGGING)
