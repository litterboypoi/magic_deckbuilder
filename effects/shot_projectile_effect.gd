class_name ShotProjectileEffect
extends Effect

var projectile_scene: PackedScene

func execute(_targets: Array[Node]) -> void:
	var player: Player = _targets[0].get_tree().get_first_node_in_group("player")
	var projectile: Projectile = projectile_scene.instantiate()
	projectile.global_position = player.shot_start_pos.global_position
	# 暂时先放到
	var projectiles: Node2D = player.get_tree().get_first_node_in_group("projectiles")
	projectiles.add_child(projectile)
