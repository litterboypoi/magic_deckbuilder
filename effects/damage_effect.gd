class_name DamageEffect
extends Effect

var amount := 0
var receiver_modifier_type := Modifier.Type.DMG_TAKEN


func execute(targets: Array[Node]) -> void:
	var promises = []
	for target in targets:
		if not target:
			continue
		if target is Enemy or target is Player:
			var promise = target.take_damage(amount, receiver_modifier_type, executor)
			promises.append(promise)
	ActionManager.push_mico_action(
		func ():
			await Promise.async_all(promises)
	)
