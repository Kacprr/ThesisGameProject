extends AnimatedSprite2D

func start_animation(duration: float = 5.0):
	play("float")
	
	await get_tree().create_timer(duration).timeout
	queue_free()
