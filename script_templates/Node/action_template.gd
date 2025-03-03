# meta-name: Action Logic
# meta-description: What happens when a action is excute.
extends Action


func enter() -> void:
	TimeSystem.tick.connect(tick)


func exit() -> void:
	TimeSystem.tick.disconnect(tick)


func excute() -> void:
	pass


func tick(delta: float) -> void:
	charging_time += delta
	if charging_time >= need_time:
		excute()
