extends Node

var paused_var

var score = 0
var goal_coin = 1

signal flip_toggled(value)

var flipped = false : set = set_flipped

func set_flipped(value):
	if flipped != value:
		flipped = value
		emit_signal("flip_toggled", flipped)

var current_checkpoint_position = Vector2.ZERO
var checkpoint_active = false

func update_checkpoint(pos: Vector2):
	current_checkpoint_position = pos
	checkpoint_active = true

func reset_checkpoint():
	checkpoint_active = false
	current_checkpoint_position = Vector2.ZERO
