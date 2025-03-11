class_name AttackAction
extends Action

@export var base_damage := 6


func do_excute(finish_callback: Callable) -> void:
	var tween := action_owner.create_tween().set_trans(Tween.TRANS_QUINT)
	var damage_effect := DamageEffect.new()
	damage_effect.executor = action_owner
	if modifiers:
		damage_effect.amount = modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	else:
		damage_effect.amount = base_damage
	damage_effect.sound = sound
	
	
	tween.tween_interval(0.25)
	
	tween.finished.connect(
		func():
			damage_effect.execute(targets)
			finish_callback.call()
	)


func get_callables() -> Array[Callable]:
	
	var callable = Callable(self, "do_excute")

	return [callable]
