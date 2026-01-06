extends Node

var paused_var

var score = 0
@export var goal_coin = 1
var red_score = 0
@export var red_goal = 1

signal flip_toggled(value)

var flipped = false : set = set_flipped

func set_flipped(value):
	if flipped != value:
		flipped = value
		emit_signal("flip_toggled", flipped)

var current_checkpoint_position = Vector2.ZERO
var checkpoint_active = false

var max_health = 100
var max_stamina = 100

var respawning = false
var coins_to_restore = 0
var red_coins_to_restore = 0

func update_checkpoint(pos: Vector2):
	current_checkpoint_position = pos
	checkpoint_active = true

func reset_checkpoint():
	checkpoint_active = false
	current_checkpoint_position = Vector2.ZERO

# Persistence
var current_keys = 0
var opened_chests = []
var collected_keys = []
var collected_coins = []

func is_chest_opened(id: String) -> bool:
	return id in opened_chests

func register_chest_opened(id: String):
	if not id in opened_chests:
		opened_chests.append(id)

func is_key_collected(id: String) -> bool:
	return id in collected_keys

func register_key_collected(id: String):
	if not id in collected_keys:
		collected_keys.append(id)
		current_keys += 1

func is_coin_collected(id: String) -> bool:
	return id in collected_coins

func register_coin_collected(id: String):
	if not id in collected_coins:
		collected_coins.append(id)

func reset_stats():
	max_health = 100
	max_stamina = 100
	current_keys = 0
	opened_chests.clear()
	collected_keys.clear()
	collected_coins.clear() # Clear coins on full reset
