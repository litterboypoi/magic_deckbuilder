extends Node2D

const ARC_POINTS := 8

@onready var area_2d: Area2D = $Area2D
@onready var card_arc: Line2D = $CanvasLayer/CardArc

var start_node: Node2D
var targeting := false
var targets: Array[Node] = []


func _ready() -> void:
	Events.enemy_aim_requested.connect(_on_enemy_aim_requested)


func _process(_delta: float) -> void:
	if not targeting:
		return

	area_2d.position = get_local_mouse_position()
	card_arc.points = _get_points()


func _input(event: InputEvent) -> void:
	if not targeting:
		return
	if event.is_action_pressed("left_mouse") and targets.size() > 0:
		enemy_aim_confirm()
		return



func _get_points() -> Array:
	var points := []
	var start := start_node.global_position
	var target := get_local_mouse_position()
	var distance := (target - start)
	
	for i in ARC_POINTS:
		var t := (1.0 / ARC_POINTS) * i
		var x := start.x + (distance.x / ARC_POINTS) * i
		var y := start.y + ease_out_cubic(t) * distance.y
		points.append(Vector2(x, y))
	
	points.append(target)
	
	return points


func ease_out_cubic(number : float) -> float:
	return 1.0 - pow(1.0 - number, 3.0)


func _on_enemy_aim_requested() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() == 0:
		# 等一下再返回，否则还没await就resolve了
		create_tween().tween_interval(0.1).finished.connect(
			func(): 
				Events.enemy_aim_confirmed.emit(targets)
		)
		return

	targeting = true
	area_2d.monitoring = true
	area_2d.monitorable = true
	start_node = get_tree().get_first_node_in_group("player")


func enemy_aim_confirm() -> void:
	targeting = false
	card_arc.clear_points()
	area_2d.position = Vector2.ZERO
	area_2d.monitoring = false
	area_2d.monitorable = false
	start_node = null
	Events.enemy_aim_confirmed.emit(targets)
	targets.clear()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if not targeting:
		return
	
	if not targets.has(area):
		targets.append(area)


func _on_area_2d_area_exited(area: Area2D) -> void:
	if not targeting:
		return
	
	targets.erase(area)
