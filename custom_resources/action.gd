class_name Action
extends Resource

signal exit_requested(action: Action)


@export var need_time: float
@export var immediately: bool = false
@export_multiline var card_text: String

# must be set when created
var action_owner: Node
var targets: Array[Node] = []
var modifiers: ModifierHandler

# change when during action
var charging_time: float = 0


func enter() -> void:
	update_action_intent_progress()
	TimeSystem.tick.connect(tick)


func exit() -> void:
	hide_action_intent()
	TimeSystem.tick.disconnect(tick)


func excute() -> void:
	pass


func tick(delta: float) -> void:
	charging_time += delta
	update_action_intent_progress()
	if charging_time >= need_time:
		excute()


func update_action_intent_progress():
	if action_owner is Player:
		action_owner.time_bar.set_time_bar(charging_time, need_time)
	

func hide_action_intent():
	if action_owner is Player:
		action_owner.time_bar.hide()
