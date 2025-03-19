class_name StatusAction
extends Action

@export var status: Status


func do_excute(finish_callback: Callable) -> void:
	pass
	#var tween := action_owner.create_tween().set_trans(Tween.TRANS_QUINT)
	#var status_effect := StatusEffect.new()
	#status_effect.executor = action_owner
	#status_effect.status = status
	#
	#tween.tween_interval(0.25)
	#
	#tween.finished.connect(
		#func():
			#status_effect.execute([])
			#finish_callback.call()
	#)


func get_callables() -> Array[Callable]:
	
	var callable = Callable(self, "do_excute")

	return [callable]
