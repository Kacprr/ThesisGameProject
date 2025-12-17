extends Node

var paused_var

signal flip_toggled(value)

#This is the global value used to determine if the world has "flipped" or not
#Used to handle which dimension the player is in
var flipped = false : set = set_flipped

func set_flipped(value):
	if flipped != value:
		flipped = value
		emit_signal("flip_toggled", flipped)
