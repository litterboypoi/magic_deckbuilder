class_name AttackAction
extends PlayerAction

@export var base_damage := 6

func _async_impl_apply(promise: Promise, player: Player):
	var tween := player.create_tween().set_trans(Tween.TRANS_QUINT)
	var damage_effect := DamageEffect.new()
	damage_effect.executor = player
	if modifiers:
		damage_effect.amount = modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	else:
		damage_effect.amount = base_damage
	
	
	tween.tween_interval(0.25)
	
	await tween.finished
	var targets = await _async_get_targets(Target.RANGE, player.get_tree())
	damage_effect.execute(targets)
	promise.resolve()
