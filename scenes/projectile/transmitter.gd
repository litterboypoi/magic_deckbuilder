class_name Transmitter
extends Node2D

@onready var arrow: Sprite2D = $Arrow
@onready var trajectory_line: TrajectoryLine = $TrajectoryLine

var speed
var gravity
var max_rebound

var is_aiming = false


func _ready() -> void:
	Events.projectile_aim_started.connect(on_projectile_aim_started)
	Events.projectile_aim_ended.connect(on_projectile_aim_ended)


func on_projectile_aim_started(_speed: float, _gravity: float, _max_rebound: int):
	is_aiming = true
	visible = true
	speed = _speed
	gravity = _gravity
	max_rebound = _max_rebound


func on_projectile_aim_ended():
	is_aiming = false
	visible = false


func _input(event: InputEvent) -> void:
	if is_aiming and event is InputEventMouseMotion:
		var direction = get_global_mouse_position() - global_position
		if direction.x < 0:
			direction = -direction
		direction = direction.normalized()
		Events.aim_direction_changed.emit(direction)
		arrow.rotation = -direction.angle_to(Vector2(1, -1))
		trajectory_line.update_trajectory(direction, speed, gravity, max_rebound)
		
