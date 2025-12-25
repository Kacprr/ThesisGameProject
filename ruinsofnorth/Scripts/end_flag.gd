extends Area2D

signal player_reached_flag

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		emit_signal("player_reached_flag")
