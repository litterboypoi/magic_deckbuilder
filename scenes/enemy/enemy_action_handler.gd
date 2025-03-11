class_name EnemyActionHandler
extends Node

@export var ai_actions: Array[AIAction] = []
@export var modifier_handler: ModifierHandler
@export var enemy: Enemy

var total_weight := 0.0

var started_flag := false
var current_action: AIAction
var charging_time: float = 0
	

func _ready() -> void:
	TimeSystem.tick.connect(_tick)
	Events.action_order_completed.connect(_on_action_order_completed)
	var copy_ai_actions: Array[AIAction] = []
	for action in ai_actions:
		copy_ai_actions.append(action.duplicate())
	ai_actions = copy_ai_actions


func _tick(delta: float) -> void:
	if current_action :
		charging_time += delta
		update_action_intent()
		if charging_time >= current_action.need_time:
			current_action.excute()


func change_action(from: AIAction, to: AIAction) -> void:
	charging_time = 0
	if current_action and current_action != from:
		return

	if current_action:
		current_action.exit()
		current_action.remove_requested.disconnect(_on_action_remove_requested)
		current_action.change_action_requested.disconnect(change_action)
	# current_action = to if not to else to.duplicate()
	current_action = to
	update_action_intent()
	if current_action:
		setup_action(current_action)
		current_action.remove_requested.connect(_on_action_remove_requested)
		current_action.change_action_requested.connect(change_action)
		current_action.enter()


func run_ai() -> void:
	if started_flag:
		return
	started_flag = true
	setup_actions()
	# NOTE 自身conditional aciton改变stats，会在exit之前触发这里，需要注意
	# 当然，在exit之前触发这里并不是什么问题，但要避免触发同一个conditional action
	# 因此只能触发一次的aciton需要在action生效前发出remove_requested
	enemy.stats.stats_changed.connect(try_switch_conditional_action)
	next_action()


func setup_actions():
	for action in ai_actions:
		setup_action(action)
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
		change_action(current_action, first_action)


func try_switch_conditional_action():
	var new_conditional_action := get_first_conditional_action()
	if new_conditional_action and current_action != new_conditional_action:
		change_action(current_action, new_conditional_action)


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


# will be called by action_order_manager
func _on_action_order_completed(action_order: ActionOrder):
	if not is_inside_tree():
		return
	if action_order.action_owner == enemy:
		next_action()


func _on_action_remove_requested(action: AIAction):
	ai_actions = ai_actions.filter(func(e): return e.id != action.id)
	setup_actions()


func update_action_intent():
	enemy.update_intent(current_action, charging_time)
