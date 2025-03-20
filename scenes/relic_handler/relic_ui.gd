class_name RelicUI
extends Control

@export var relic: Relic : set = set_relic

@onready var icon: TextureRect = $Icon
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var count: Label = $Count


func set_relic(new_relic: Relic) -> void:
	if not is_node_ready():
		await ready

	relic = new_relic
	icon.texture = relic.icon


func flash() -> void:
	animation_player.play("flash")


func set_count(num: int) -> void:
	count.visible = num != 0
	count.text = str(num)


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		Events.relic_tooltip_requested.emit(relic)
