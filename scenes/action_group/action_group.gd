class_name ActionGroup
extends Node

var actions: Array[Action] = []
var tick_index: int = 0
var max_tick_length: int = 7

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
