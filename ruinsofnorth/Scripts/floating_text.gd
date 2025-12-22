extends Node2D

@onready var label: Label = $Label

func start(text: String, color: Color):
	label.text = text
	label.modulate = color
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position", position + Vector2(0, -50), 1.0).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 1.0).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free).set_delay(1.0)
