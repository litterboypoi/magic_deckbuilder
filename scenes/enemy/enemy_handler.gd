class_name EnemyHandler
extends Node2D

var acting_enemies: Array[Enemy] = []


func _ready() -> void:
	Events.enemy_died.connect(_on_enemy_died)
	Events.enemy_action_completed.connect(_on_enemy_action_completed)
	Events.player_hand_drawn.connect(_on_player_hand_drawn)


func setup_enemies(battle_stats: BattleStats) -> void:
	if not battle_stats:
		return
	
	for enemy: Enemy in get_children():
		enemy.queue_free()
	
	var all_new_enemies := battle_stats.enemies.instantiate()
	
	for new_enemy: Node2D in all_new_enemies.get_children():
		var new_enemy_child := new_enemy.duplicate() as Enemy
		add_child(new_enemy_child)
		new_enemy_child.status_handler.statuses_applied.connect(_on_enemy_statuses_applied.bind(new_enemy_child))
		
	all_new_enemies.queue_free()


func reset_enemy_actions() -> void:
	for enemy: Enemy in get_children():
		enemy.current_action = null
		enemy.update_action()


func start_turn() -> void:
	if get_child_count() == 0:
		return
	
	acting_enemies.clear()
	for enemy: Enemy in get_children():
		acting_enemies.append(enemy)

	_start_next_enemy_turn()


func _start_next_enemy_turn() -> void:
	if acting_enemies.is_empty():
		Events.enemy_turn_ended.emit()
		return
	
	acting_enemies[0].status_handler.apply_statuses_by_type(LegalStatus.Type.START_OF_TURN)


func _on_enemy_statuses_applied(type: LegalStatus.Type, enemy: Enemy) -> void:
	match type:
		LegalStatus.Type.START_OF_TURN:
			enemy.do_turn()
		LegalStatus.Type.END_OF_TURN:
			acting_enemies.erase(enemy)
			_start_next_enemy_turn()


func _on_enemy_died(enemy: Enemy) -> void:
	var is_enemy_turn := acting_enemies.size() > 0
	acting_enemies.erase(enemy)
	
	if is_enemy_turn:
		_start_next_enemy_turn()


func _on_enemy_action_completed(enemy: Enemy) -> void:
	enemy.status_handler.apply_statuses_by_type(LegalStatus.Type.END_OF_TURN)


func _on_player_hand_drawn() -> void:
	for enemy: Enemy in get_children():
		enemy.legal_update_intent()
