class_name Battle
extends Node2D

@export var battle_stats: BattleStats
@export var char_stats: CharacterStats
@export var music: AudioStream
@export var relics: RelicHandler

@onready var battle_ui: BattleUI = $BattleUI
@onready var player_handler: PlayerHandler = $PlayerHandler
@onready var enemy_handler: EnemyHandler = $EnemyHandler
@onready var player: Player = $Player
@onready var location_manager: LocationManager = $LocationManager



func _ready() -> void:
	enemy_handler.child_order_changed.connect(_on_enemies_child_order_changed)
	Events.enemy_turn_ended.connect(_on_enemy_turn_ended)
	
	Events.player_turn_ended.connect(player_handler.end_turn)
	Events.player_hand_discarded.connect(tick)
	Events.player_died.connect(_on_player_died)


func _exit_tree() -> void:
	ActionManager.clear()


func start_battle() -> void:
	get_tree().paused = false
	MusicPlayer.play(music, true)
	ActionManager.clear()
	TimeSystem.time_frozen()
	
	battle_ui.char_stats = char_stats
	player.stats = char_stats
	player_handler.relics = relics
	enemy_handler.setup_enemies(battle_stats)
	
	location_manager.init_units_position()
	ActionManager.push_action(
		func ():
			Events.battle_started.emit()
	).then(
		func (_data):
			player_handler.start_battle(char_stats)
			battle_ui.initialize_card_pile_ui()
			start_new_turn()
	)
	


func start_new_turn():
	player.action_group.tick_index = 0
	for enemy: Enemy in enemy_handler.get_children():
		enemy.action_group.tick_index = 0
	enemy_handler.reset_enemy_actions()
	player_handler.start_turn()


func tick() -> void:
	player.action_group.tick_index += 1
	for enemy: Enemy in enemy_handler.get_children():
		enemy.action_group.tick_index +=1
	await ActionManager.push_action(
		func ():
			Events.battle_ticked.emit()
	).async_awaiter()
	await player_handler.tick()
	enemy_handler.tick()


func _on_enemies_child_order_changed() -> void:
	if enemy_handler.get_child_count() == 0 and is_instance_valid(relics):
		ActionManager.push_action(
			func ():
				Events.battle_ended.emit()
		).then(
			func (_data):
				Events.battle_over_screen_requested.emit("Victorious!", BattleOverPanel.Type.WIN)
		)


func _on_enemy_turn_ended() -> void:
	if player_handler.is_action_group_reach_end():
		start_new_turn()
	else:
		tick()


func _on_player_died() -> void:
	Events.battle_over_screen_requested.emit("Game Over!", BattleOverPanel.Type.LOSE)
	SaveGame.delete_data()
