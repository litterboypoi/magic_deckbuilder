class_name LocationManager
extends Node

signal move_finished

@export var player: Player
@export var enemy_handler: EnemyHandler
@export var zero_location_marker: Marker2D
@onready var camera_2d: Camera2D = $Camera2D

const px_per_cell := Vector2(25, 0)


func get_units_in_battle():
	var units = []
	if is_instance_valid(player) and not player.is_queued_for_deletion():
		units.append(player)
	for enemy in enemy_handler.get_children():
		if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
			units.append(enemy)
	return units


func get_units_in_range(left: int, right: int):
	var units = []
	for unit in get_units_in_battle():
		if unit is Player or unit is Enemy:
			if unit.location >= left and unit.location <= right:
				units.append(unit)
		else:
			continue
	return units


func move_unit(unit: Node2D, movement: int):
	if movement == 0 or not (unit is Player or unit is Enemy):
		move_finished.emit()
		return
	var one_move = 1 if movement > 0 else -1
	var next_step_location = unit.location + one_move
	# TODO 要不要考虑穿过同方单位的情况？
	if get_units_in_range(next_step_location, next_step_location).size() != 0:
		move_finished.emit()
		return

	var next_step_position = unit.position + px_per_cell * one_move
	var tween = create_tween()
	tween.tween_property(unit, "position", next_step_position, 0.4)
	tween.set_parallel()
	tween.tween_property(camera_2d, "position", get_camera_position_of_next_move(next_step_position), 0.4)
	tween.tween_callback(
		func():
			unit.location = next_step_location
			# todo emit signal
	)
	tween.finished.connect(
		func():
			move_unit(unit, movement - one_move)
	)




func get_camera_position_of_next_move(next_step_position: Vector2):
	var camera_position = camera_2d.position
	var camera_size = camera_2d.get_viewport_rect().size
	var padding = 20
	var camera_left = camera_position.x - camera_size.x / 2 + padding
	var camera_right = camera_position.x + camera_size.x / 2 - padding
	if next_step_position.x > camera_right:
		return camera_position + px_per_cell
	elif next_step_position.x < camera_left:
		return camera_position - px_per_cell
	else:
		return camera_position



func init_units_position():
	# TODO 临时的测试方案
	var enemy_start_location = 2
	for unit in get_units_in_battle():
		if unit is Player:
			unit.location = -2
			unit.position = zero_location_marker.position + px_per_cell * unit.location
		else:
			unit.location = enemy_start_location
			unit.position = zero_location_marker.position + px_per_cell * unit.location
			enemy_start_location += 1
