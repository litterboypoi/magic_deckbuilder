class_name EnemyActionHandler
extends Node

@export var ai_actions: Array[AIAction] = []
@export var modifier_handler: ModifierHandler
@export var enemy: Enemy

@onready var total_weight := 0.0

var current_action: AIAction : set = _set_current_action


func _set_current_action(value: AIAction) -> void:
	# exit pre action
	if current_action:
		current_action.exit_requested.disconnect(_on_action_exit_requested)
		current_action.exit()
	# enter new action
	current_action = value
	if current_action:
		current_action.exit_requested.connect(_on_action_exit_requested)
		current_action.enter()
	

func _ready() -> void:
	var copy_ai_actions: Array[AIAction] = []
	for action in ai_actions:
		copy_ai_actions.append(action.duplicate())
	ai_actions = copy_ai_actions

func run_ai() -> void:
	setup_actions()
	enemy.stats.stats_changed.connect(try_switch_conditional_action)
	next_action()


func setup_actions():
	var player = get_tree().get_first_node_in_group("player")
	for action in ai_actions:
		action.action_owner = enemy
		action.modifiers = modifier_handler
		action.targets = [player]

		# setup_chances
		if action.type == AIAction.Type.CHANCE_BASED:
			total_weight += action.chance_weight
			action.accumulated_weight = total_weight


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
	
