extends Area2D

@export var duration: float = 5.0
@export var heal_per_second: int = 5
@export var audio_stream: AudioStream = preload("res://Assets/sounds/power_up.wav")

@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer

func _on_body_entered(body: Node2D):
	if body.is_in_group("Player") and body.has_method("start_heal_over_time"):
		
		body.start_heal_over_time(heal_per_second, duration)
		
		audio_player.stream = audio_stream
		audio_player.play()
		
		$CollisionShape2D.set_deferred("disabled", true)
		$Sprite2D.visible = false
		
		await audio_player.finished
		queue_free()
