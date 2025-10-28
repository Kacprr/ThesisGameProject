extends Area2D
class_name HealthPickup

@export var healing_amount: int = 1
@export var audio_stream: AudioStream = preload("res://Assets/sounds/power_up.wav")

@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer
@onready var respawn_timer: Timer = $RespawnTimer

func _ready():
	add_to_group("pickup")
	respawn_timer.wait_time = 5.0
	respawn_timer.one_shot = true

func _on_body_entered(body: Node2D):
	if body.is_in_group("Player") and body.has_method("heal"):
		body.heal(healing_amount)
		
		audio_player.stream = audio_stream
		audio_player.play()
		
		$CollisionShape2D.set_deferred("disabled", true)
		$Sprite2D.visible = false
		
		respawn_timer.start()

func _on_respawn_timer_timeout():
	$CollisionShape2D.set_deferred("disabled", false)
	$Sprite2D.visible = true
