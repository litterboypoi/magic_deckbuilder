class_name AIAction
extends Action

enum Type {CONDITIONAL, CHANCE_BASED}

@export var type: Type
@export_range(0.0, 10.0) var chance_weight := 0.0

var accumulated_weight := 0.0


func is_performable() -> bool:
	return false
