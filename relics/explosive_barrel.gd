extends Relic

@export var damage := 2

var relic_ui: RelicUI

func initialize_relic(owner: RelicUI) -> void:
	relic_ui = owner
	Events.battle_started.connect(_on_battle_started)


func deactivate_relic(_owner: RelicUI) -> void:
	Events.battle_ticked.disconnect(_on_battle_started)


func _on_battle_started() -> void:
	var enemies := relic_ui.get_tree().get_nodes_in_group("enemies")
	var damage_effect := DamageEffect.new()
	damage_effect.amount = damage
	damage_effect.receiver_modifier_type = Modifier.Type.NO_MODIFIER
	damage_effect.execute(enemies)
	
	# FIXME: 等execute之后再flash
	# 可能也不太需要，因为收到事件时一般都意味着前一个action已经执行完了
	relic_ui.flash()
