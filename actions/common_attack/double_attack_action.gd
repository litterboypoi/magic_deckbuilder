class_name DoubleAttackAction
extends PlayerAction

@export var base_damage := 6

func _async_impl_apply(promise: Promise, player: Player):
	var damage_effect := DamageEffect.new()
	damage_effect.executor = player
	if modifiers:
		damage_effect.amount = modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	else:
		damage_effect.amount = base_damage
	
	
	await player.get_tree().create_timer(0.3).timeout
	var targets = await _async_get_targets(Target.RANGE, player.get_tree())
	damage_effect.execute(targets)
	await player.get_tree().create_timer(0.3).timeout
	targets = await _async_get_targets(Target.RANGE, player.get_tree())
	damage_effect.execute(targets)
	promise.resolve()
