class_name AttackAction
extends Action

@export var base_damage := 6


func do_excute(order: ActionOrder) -> void:
	var tween := action_owner.create_tween().set_trans(Tween.TRANS_QUINT)
	var damage_effect := DamageEffect.new()
	if modifiers:
		damage_effect.amount = modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	else:
		damage_effect.amount = base_damage
	damage_effect.sound = sound
	
	
	tween.tween_interval(0.25)
	
	tween.finished.connect(
		func():
			damage_effect.execute(targets)
			order.finished.emit()
			exit_requested.emit(self)
	)
