class_name Action
extends Resource

signal exit_requested(action: Action)


@export var need_time: float
@export var immediately: bool = false
@export_multiline var card_text: String

# must be set when created
var targets: Array[Node] = []
var modifiers: ModifierHandler

# change when during action
var charging_time: float = 0


func enter() -> void:
	TimeSystem.tick.connect(tick)


func exit() -> void:
	TimeSystem.tick.disconnect(tick)


func excute() -> void:
	pass


func tick(delta: float) -> void:
	charging_time += delta
	if charging_time >= need_time:
		excute()
