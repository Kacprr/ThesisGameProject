extends Area2D

@onready var _animated_sprite = $AnimatedSprite2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	_animated_sprite.play("new_animation")
	# Auto-destroy after 0.3 seconds even if it misses
	await get_tree().create_timer(0.5).timeout
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	print("Attack hit: ", body.name)
	if body.is_in_group("enemies"):
		body.queue_free()

func set_flip():
	scale.x = -1
