class_name EnemyActionHandler
extends Node

@export var ai_actions: Array[AIAction] = []
@export var modifier_handler: ModifierHandler
@export var enemy: Enemy

@onready var total_weight := 0.0

var started_flag := false
var current_action: AIAction : set = _set_current_action
var is_current_action_doing_excute := false


func _set_current_action(value: AIAction) -> void:
	# exit pre action
	if current_action:
		current_action.exit()
		current_action.exit_requested.disconnect(_on_action_exit_requested)
	# enter new action
	# 每次都duplicate一份，避免污染ai_acitons的原始数据
	current_action = value if not value else value.duplicate()
	if current_action:
		setup_action(current_action)
		current_action.exit_requested.connect(_on_action_exit_requested)
		current_action.remove_requested.connect(_on_action_remove_requested)
		current_action.change_action_requested.connect(_on_change_action_requested)
		current_action.excute_requested.connect(_on_excute_requested)
		current_action.excute_finished.connect(_on_excute_finished)
		current_action.enter()
	

func _ready() -> void:
	Events.action_excute_permited.connect(_on_action_excute_premited)
	Events.enemy_died.connect(_on_enemy_died)
	var copy_ai_actions: Array[AIAction] = []
	for action in ai_actions:
		copy_ai_actions.append(action.duplicate())
	ai_actions = copy_ai_actions

func run_ai() -> void:
	if started_flag:
		return
	started_flag = true
	setup_chances()
	# NOTE 自身conditional aciton改变stats，会在exit之前触发这里，需要注意
	# 当然，在exit之前触发这里并不是什么问题，但要避免触发同一个conditional action
	# 因此只能触发一次的aciton需要在action生效前发出remove_requested
	enemy.stats.stats_changed.connect(try_switch_conditional_action)
	next_action()


func setup_chances():
	for action in ai_actions:
		# setup_chances
		if action.type == AIAction.Type.CHANCE_BASED:
			total_weight += action.chance_weight
			action.accumulated_weight = total_weight


func setup_action(action: AIAction):
	action.action_owner = enemy
	action.modifiers = modifier_handler
	action.targets = [get_tree().get_first_node_in_group("player")]


func next_action():
	var first_action := get_chance_based_action()
	if first_action:
		current_action = first_action


func try_switch_conditional_action():
	var new_conditional_action := get_first_conditional_action()
	if new_conditional_action and current_action != new_conditional_action:
		current_action = new_conditional_action


func get_chance_based_action() -> AIAction:
	var roll := RNG.instance.randf_range(0.0, total_weight)
	
	for action in ai_actions:
		if action.type != AIAction.Type.CHANCE_BASED:
			continue
		
		if action.accumulated_weight > roll:
			return action
	
	return null



func get_first_conditional_action() -> AIAction:
	for action in ai_actions:
		if action.type != AIAction.Type.CONDITIONAL:
			continue
			
		if action.is_performable():
			return action
	
	return null


func _on_action_exit_requested(_action: Action):
	current_action = null
	next_action()
	


func _on_action_remove_requested(action: AIAction):
	ai_actions = ai_actions.filter(func(e): return e.id != action.id)
	setup_chances()


func _on_change_action_requested(new_action: Action, _old_action: Action):
	current_action = new_action as AIAction


func _on_excute_requested(action: Action):
	Events.action_excute_requested.emit(action)
	# TODO player action 期间可能要做一些禁用操作，可能在这里也可能在action_order_manager中做


func _on_action_excute_premited(action: Action):
	if action == current_action:
		is_current_action_doing_excute = true
		current_action.do_excute()


func _on_excute_finished(action: Action):
	is_current_action_doing_excute = false
	Events.action_excute_completed.emit(action)


func _on_enemy_died(_enemy: Enemy):
	if enemy == _enemy:
		if current_action:
			if is_current_action_doing_excute:
				Events.action_excute_completed.emit(current_action)
			current_action.exit()
