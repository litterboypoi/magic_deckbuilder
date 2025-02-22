class_name EnemyAction
extends Node

enum Type {CONDITIONAL, CHANCE_BASED}

@export var intent: Intent
@export var sound: AudioStream
@export var type: Type
@export_range(1, 10) var cost_turn: int = 1
@export_range(0.0, 10.0) var chance_weight := 0.0

@onready var accumulated_weight := 0.0

var enemy: Enemy
var target: Node2D

var current_turn: int = 0


func is_performable() -> bool:
	return false


func move_on_turn():
	current_turn += 1


func perform_action() -> void:
	pass


func update_intent_text() -> void:
	intent.current_text = intent.base_text
