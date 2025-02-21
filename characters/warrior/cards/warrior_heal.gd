extends Card

var base_heal := 3


func apply_effects(targets: Array[Node], _modifiers: ModifierHandler) -> void:
	var heal_effect := HealEffect.new()
	heal_effect.amount = base_heal
	heal_effect.execute(targets)
