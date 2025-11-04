extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var camera = body.get_node_or_null("Camera2D")
		if camera:
			camera.limit_bottom = 999
			
			camera.position_smoothing_enabled = true
			camera.position_smoothing_speed = 5.0
			camera.limit_smoothed = true
		
		Engine.time_scale = 0.5
		if body.has_method("die"):
			body.die()
		timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1
