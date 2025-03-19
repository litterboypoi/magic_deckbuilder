class_name Action
extends Resource

enum Target {SELF, RANGE, SELECT}

@export var id: String
@export_range(1, 10) var tick: int = 1
@export var cost = 0
@export_multiline var card_text: String

# must be set when created
var modifiers: ModifierHandler


func async_apply(_owner: Node) -> Promise:
	return null


func get_default_tooltip() -> String:
	return card_text


func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return card_text
