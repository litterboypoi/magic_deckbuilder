class_name AttackAction
extends PlayerAction

@export var base_damage := 6

func _async_impl_apply():
	await _async_push_action(
		func ():
			await player.create_tween().tween_interval(0.1).finished
			var targets = await _async_get_targets(Target.RANGE)
			var damage_effect := DamageEffect.new()
			damage_effect.executor = player
			damage_effect.amount = player.modifier_handler.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
			damage_effect.execute(targets)
	)
