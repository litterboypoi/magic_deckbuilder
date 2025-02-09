class_name Transmitter
extends Node2D

const valid_distance: float = 20

@onready var arrow: Sprite2D = $Arrow
@onready var trajectory_line: TrajectoryLine = $TrajectoryLine

@export var projectile: Projectile

var is_hover = false
var is_holding = false

var start_mouse_postion: Vector2
var mouse_drag_offset: Vector2
var trajectory_points : Array = []  # 存储轨迹点


func _input(event: InputEvent) -> void:
	if event.is_action_released("left_mouse"):
		is_holding = false
		arrow.visible = false
		trajectory_line.visible = false
		if is_valid_distance(mouse_drag_offset):
			projectile.fire(mouse_drag_offset)
			# 发射后禁用瞄准功能
			queue_free()
	elif is_holding and event is InputEventMouseMotion:
		mouse_drag_offset = start_mouse_postion - get_global_mouse_position()
		if is_valid_distance(mouse_drag_offset):
			arrow.visible = true
			arrow.rotation = -mouse_drag_offset.angle_to(Vector2(1, -1))
			trajectory_line.visible = true
			trajectory_line.update_trajectory(mouse_drag_offset, projectile.v_speed * projectile.UNIT_SPEED, projectile.a_gravity * projectile.UNIT_GRAVITY, projectile.max_rebound)
		else:
			arrow.visible = false
			trajectory_line.visible = false
	elif is_hover and event.is_action_pressed("left_mouse"):
		is_holding = true
		start_mouse_postion = get_global_mouse_position()
		

func is_valid_distance(offset: Vector2) -> bool:
	return offset.length() > valid_distance


func draw_trajectory(direction: Vector2):
	trajectory_points.clear()  # 清空之前的轨迹

	var time_step : float = 0.1  # 每个时间步的间隔
	var max_time : float = 2.0  # 最大计算时间，用来限制轨迹的长度
	var time : float = 0.0  # 起始时间
	var p0 : Vector2 = Vector2.ZERO # projectile.position  # 初始化子弹位置

	# 根据时间步长逐步计算轨迹
	while time <= max_time:
		# 计算当前时间点的子弹位置（包含风力的影响）
		var position = p0 + projectile.v_speed * projectile.UNIT_SPEED * direction.normalized() * time + 0.5 * projectile.a_gravity * projectile.UNIT_GRAVITY * Vector2.DOWN * time * time
		trajectory_points.append(position)
		
		time += time_step  # 增加时间步长

	# 绘制轨迹
	trajectory_line.points = trajectory_points


func _on_projectile_mouse_entered() -> void:
	is_hover = true


func _on_projectile_mouse_exited() -> void:
	is_hover = false
