class_name CrabRealtimeMegaBlockAction
extends AIAction

@export var block := 15
@export var hp_threshold := 6


func is_performable() -> bool:
	if action_owner is Enemy:
		var enemy := action_owner as Enemy
		return enemy.stats.health <= hp_threshold
	return false

	
func do_excute(finish_callback: Callable) -> void:
	remove_requested.emit(self)
	
	var tween := action_owner.create_tween().set_trans(Tween.TRANS_QUINT)
	
	var block_effect := BlockEffect.new()
	block_effect.amount = block
	block_effect.sound = sound
	
	
	tween.tween_interval(0.25)
	
	tween.finished.connect(
		func():
			block_effect.execute([action_owner])
			finish_callback.call()
	)


func get_callables() -> Array[Callable]:
	
	var callable = Callable(self, "do_excute")

	return [callable]
