class_name Spikes
extends Status

@export var sound: AudioStream = preload("res://art/axe.ogg")

func initialize_status(_target: Node) -> void:
	if _target is Enemy or _target is Player:
		_target.damage_taken.connect(_on_damage_taken)


func _on_damage_taken(_amount: int, _hp_amout: int, damage_form: Object) -> void:
	if damage_form is Enemy or damage_form is Player:
		var damage_effect: DamageEffect = DamageEffect.new()
		damage_effect.amount = stacks
		damage_effect.receiver_modifier_type = Modifier.Type.NO_MODIFIER
		damage_effect.execute([damage_form])
		SFXPlayer.play(sound)
