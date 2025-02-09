class_name Projectile
extends CharacterBody2D

@export var UNIT_SPEED: float = 100
@export var UNIT_GRAVITY: float = 50
@export var ELASTICITY: float = 0.7

var v_speed: int = 1
var a_gravity: int = 1
var max_rebound: int = 1

var current_rebound_count = 0
var firing: bool = false
var time_scale: float = 0


func _ready() -> void:
	TimeSystem.time_scale_changed.connect(on_time_scale_changed)


func _process(delta: float) -> void:
	delta *= time_scale
	if firing:
		# 重力
		velocity += a_gravity * UNIT_GRAVITY * Vector2.DOWN * delta
		# 处理碰撞
		if current_rebound_count < max_rebound:
			var collision = move_and_collide(velocity * delta)
			if collision and current_rebound_count < max_rebound:
				velocity = velocity.bounce(collision.get_normal()) * ELASTICITY
				current_rebound_count += 1
		else:
		# 只根据当前速度更新位置
			position += velocity * delta
	


func fire(direction: Vector2) -> void:
	firing = true
	velocity = v_speed * UNIT_SPEED * direction.normalized()
	

func on_time_scale_changed(scale: float):
	time_scale = scale
