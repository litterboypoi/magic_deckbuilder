extends Card

var base_block := 7
var amount := 1


func apply_effects(targets: Array[Node], _modifiers: ModifierHandler) -> void:
	var block_effect := BlockEffect.new()
	block_effect.amount = base_block
	block_effect.sound = sound
	block_effect.execute(targets)

	var exhaust_random_effect := DiscardSelectedEffect.new()
	exhaust_random_effect.amount = amount
	exhaust_random_effect.execute(targets)
	
