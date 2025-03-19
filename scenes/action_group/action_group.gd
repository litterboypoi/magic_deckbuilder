class_name ActionGroup
extends Control

@onready var index_label: Label = $VBoxContainer/IndexLabel
@onready var action_labels: VBoxContainer = $VBoxContainer/ActionLabels

var actions: Array[Action] = []
var tick_index: int = 0 : set = set_tick_index
var max_tick_length: int = 7


func set_tick_index(val: int):
	tick_index = val
	index_label.text = "index: %d" % tick_index


func clear() -> void:
	actions.clear()
	for child in action_labels.get_children():
		child.queue_free()


func append_action(new_action: Action):
	actions.append(new_action)
	for child in action_labels.get_children():
		child.queue_free()
	var sum = 0
	for action in actions:
		var label = Label.new()
		label.text = "%s : %d--%d" % [action.get_default_tooltip(), sum + 1, sum + action.tick]
		sum += action.tick
		action_labels.add_child(label)


func get_tick_length() -> int:
	var length := 0
	for action in actions:
		length += action.tick
	return length


func get_reach_action() -> Action:
	var sum := 0
	for action in actions:
		sum += action.tick
		if tick_index == sum:
			return action
	return null
