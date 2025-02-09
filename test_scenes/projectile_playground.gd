extends Node2D

const PROJECTILE = preload("res://scenes/projectile/Projectile.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right_mouse"):
		var new_projectile = PROJECTILE.instantiate()
		new_projectile.global_position = get_global_mouse_position()
		add_child(new_projectile)
	if event.is_action_pressed("pause"):
		TimeSystem.request_time(2)
