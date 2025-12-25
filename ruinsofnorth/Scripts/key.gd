extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("add_keys"):
		print("player entered key")
		body.add_keys()
		queue_free()
	else:
		pass
