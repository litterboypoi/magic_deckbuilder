class_name CrabRealtimeAttackAction
extends AIAction

@export var base_damage := 6

func excute() -> void:
	var damage_effect := DamageEffect.new()
	if modifiers:
		damage_effect.amount = modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	else:
		damage_effect.amount = base_damage
	damage_effect.sound = sound
	damage_effect.execute(targets)
	
	exit_requested.emit(self)
