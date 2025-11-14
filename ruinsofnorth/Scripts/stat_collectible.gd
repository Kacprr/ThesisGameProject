extends Node2D
class_name StatCollectible

@export var min_bonus: int = 5    # Minimum random increase
@export var max_bonus: int = 15   # Maximum random increase
@export var pickup_sound: AudioStream = preload("res://Assets/sounds/power_up.wav")

enum UpgradeType { HEALTH, STAMINA }
@onready var health_area: Area2D = $HealthCollectibleArea
@onready var stamina_area: Area2D = $StaminaCollectibleArea

@onready var health_sprite: AnimatedSprite2D = $HealthCollectibleArea/HealthSprite
@onready var stamina_sprite: AnimatedSprite2D = $StaminaCollectibleArea/StaminaSprite

@onready var health_collision: CollisionShape2D = $HealthCollectibleArea/HealthCollision
@onready var stamina_collision: CollisionShape2D = $StaminaCollectibleArea/StaminaCollision


@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer

func _ready():
	# 1. Hide the visual elements until the choice is made
	health_area.visible = false
	stamina_area.visible = false
	
	var player = get_tree().get_first_node_in_group("Player")
	
	if player:
		process_upgrade_choice(player)
	queue_free()

func process_upgrade_choice(player: CharacterBody2D):
	var bonus = randi_range(min_bonus, max_bonus)
	
	var random_choice = randi() % 2
	var type = UpgradeType.HEALTH if random_choice == 0 else UpgradeType.STAMINA
	
	if type == UpgradeType.HEALTH:
		if player.has_method("upgrade_max_health"):
			player.upgrade_max_health(bonus)
			play_pickup_effect(health_sprite)
			
	elif type == UpgradeType.STAMINA:
		if player.has_method("upgrade_max_stamina"):
			player.upgrade_max_stamina(bonus)
			play_pickup_effect(stamina_sprite)

func play_pickup_effect(sprite_to_show: AnimatedSprite2D):
	sprite_to_show.visible = true
	audio_player.stream = pickup_sound
	audio_player.play()
	
	await get_tree().create_timer(0.3).timeout
	sprite_to_show.visible = false
	await audio_player.finished
	
	pass
