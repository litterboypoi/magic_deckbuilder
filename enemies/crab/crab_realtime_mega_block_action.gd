class_name CrabRealtimeMegaBlockAction
extends AIAction

@export var block := 15
@export var hp_threshold := 6


func is_performable() -> bool:
	if action_owner is Enemy:
		var enemy := action_owner as Enemy
		return enemy.stats.health <= hp_threshold
	return false


func excute() -> void:
	remove_requested.emit(self)

	var block_effect := BlockEffect.new()
	block_effect.amount = block
	block_effect.sound = sound
	block_effect.execute([action_owner])

	exit_requested.emit(self)
	
