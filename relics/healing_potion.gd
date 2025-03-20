extends Relic

@export var heal_amount := 6

const active_required_ticks: int = 4
var ticks: int = 0

var relic_ui: RelicUI
func initialize_relic(owner: RelicUI) -> void:
	relic_ui = owner
	Events.battle_ticked.connect(_on_tick)


func deactivate_relic(_owner: RelicUI) -> void:
	Events.battle_ticked.disconnect(_on_tick)


func _on_tick():
	ticks += 1
	if ticks >= active_required_ticks:
		ticks = 0
		var player := relic_ui.get_tree().get_first_node_in_group("player") as Player
		if player:
			player.stats.heal(heal_amount)
			relic_ui.flash()
	relic_ui.set_count(ticks)
