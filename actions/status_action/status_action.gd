class_name StatusAction
extends PlayerAction

@export var status: Status

func _async_impl_apply():
	await _async_push_action(
		func ():
			await player.create_tween().tween_interval(0.1).finished
			var targets = await _async_get_targets(Target.SELF)
			var status_effect := StatusEffect.new()
			status_effect.executor = player
			status_effect.status = status
			status_effect.execute(targets)
	)
