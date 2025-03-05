class_name AIAction
extends Action

enum Type {CONDITIONAL, CHANCE_BASED}

@export var intent: Intent
@export var type: Type
@export_range(0.0, 10.0) var chance_weight := 0.0

var accumulated_weight := 0.0


# use for check conditional action
func is_performable() -> bool:
	return false


func update_intent_text() -> void:
	intent.current_text = intent.base_text
