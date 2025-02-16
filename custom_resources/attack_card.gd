class_name AttackCard
extends Card


func apply_effects_v2(player: Player, direction: Vector2, _modifiers: ModifierHandler) -> void:
	var projectile: Projectile = attack_projectile.instantiate()
	projectile.global_position = player.transmitter.global_position
	# 暂时先放到
	var projectiles: Node2D = player.get_tree().get_first_node_in_group("projectiles")
	projectiles.add_child(projectile)
	projectile.fire(direction)
	
