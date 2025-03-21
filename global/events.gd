extends Node

# Card-related events
signal card_drag_started(card_ui: CardUI)
signal card_drag_ended(card_ui: CardUI)
signal card_aim_started(card_ui: CardUI)
signal card_aim_ended(card_ui: CardUI)
signal card_played(card: Card)
signal card_tooltip_requested(card: Card)
signal tooltip_hide_requested

# Battle-related events
signal battle_started
signal battle_ended
signal battle_ticked

# BattleUI-related events
signal battle_ui_mask_show_requested
signal battle_ui_mask_hide_requested
signal select_hand_requested(select_count: int, reason: String, select_optional: bool)
signal hand_card_selected(card_ui: CardUI)
signal hand_cards_select_confirmed(cards: Array[CardUI])
signal enemy_aim_requested
signal enemy_aim_confirmed(enemies: Array[Node])

# Aim-related events
signal projectile_aim_started(speed: float, gravity: float, max_rebound: int)
signal projectile_aim_ended
signal aim_direction_changed(diretion: Vector2)


# Player-related events
signal player_hand_drawn
signal player_hand_discarded
signal player_turn_ended
signal player_hit
signal player_died
signal player_card_played(card: Card)

# Enemy-related events
signal enemy_action_completed(enemy: Enemy)
signal enemy_turn_ended
signal enemy_died(enemy: Enemy)

# Battle-related events
signal battle_over_screen_requested(text: String, type: BattleOverPanel.Type)
signal battle_won
signal status_tooltip_requested(statuses: Array[LegalStatus])

# ActionOrder-related events
signal action_order_requested(action: ActionOrder)
signal action_order_completed(action: ActionOrder)
signal action_excute_requested(action: Action)
signal action_excute_completed(action: Action)
signal action_excute_permited(action: Action)

# Map-related events
signal map_exited(room: Room)

# Shop-related events
signal shop_entered(shop: Shop)
signal shop_relic_bought(relic: Relic, gold_cost: int)
signal shop_card_bought(card: Card, gold_cost: int)
signal shop_exited

# Campfire-related events
signal campfire_exited

# Battle Reward-related events
signal battle_reward_exited

# Treasure Room-related events
signal treasure_room_exited(found_relic: Relic)

# Relic-related events
signal relic_tooltip_requested(relic: Relic)

# Random Event room-related events
signal event_room_exited
