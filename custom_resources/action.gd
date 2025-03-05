class_name Action
extends Resource

signal exit_requested(action: Action)
signal change_action_requested(new_action: Action, old_action: Action)


@export var id: String
@export var need_time: float
@export var immediately: bool = false
@export_multiline var card_text: String
@export var sound: AudioStream

# must be set when created
var action_owner: Node
var targets: Array[Node] = []
var modifiers: ModifierHandler

# change when during action
var charging_time: float = 0


func enter() -> void:
	update_action_intent()
	TimeSystem.tick.connect(tick)


func exit() -> void:
	hide_action_intent()
	TimeSystem.tick.disconnect(tick)


func excute() -> void:
	pass


func tick(delta: float) -> void:
	charging_time += delta
	update_action_intent()
	if charging_time >= need_time:
		excute()


func update_action_intent():
	if action_owner is Player:
		action_owner.time_bar.set_time_bar(charging_time, need_time)
	elif action_owner is Enemy:
		action_owner.update_intent(self)
	

func hide_action_intent():
	if action_owner is Player:
		action_owner.time_bar.hide()
	elif action_owner is Enemy:
		action_owner.update_intent(null)


#func copy() -> Action:
	#var new_action = duplicate()
	#for property in get_property_list():
		#if get(property.name) is Action:
			#continue
		#new_action.set(property.name, get(property.name))
	#return new_action
