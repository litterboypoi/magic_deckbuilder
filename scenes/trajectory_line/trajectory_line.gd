class_name TrajectoryLine
extends Line2D

@export var collision_shape: CollisionShape2D
@onready var collision_test: CharacterBody2D = $CollisionTest


func _ready() -> void:
	collision_test.add_child(collision_shape.duplicate())


func update_trajectory(direction: Vector2, speed: float, gravity: float, max_rebound: int):
	clear_points()
	

	var time_step : float = 0.01  # 每个时间步的间隔
	var max_time : float = 3.0  # 最大计算时间，用来限制轨迹的长度
	var time : float = 0.0  # 起始时间
	var vel = direction.normalized() * speed
	var g = gravity * Vector2.DOWN
	var pos : Vector2 = Vector2.ZERO # projectile.position  # 初始化子弹位置
	var current_rebound_count = 0

	# 根据时间步长逐步计算轨迹
	while time <= max_time:
		add_point(pos)
		# 让碰撞检测体与预测线位置一致
		collision_test.position = pos
		vel += g * time_step
		var collision = collision_test.move_and_collide(vel * time_step, true)
		if collision and current_rebound_count < max_rebound:
			print(collision.get_normal())
			#vel = vel.bounce(collision.get_normal()) * 0.7
			vel = Vector2(vel.x, -vel.y * 0.7)
			current_rebound_count += 1
		pos += vel * time_step
		time += time_step  # 增加时间步长
