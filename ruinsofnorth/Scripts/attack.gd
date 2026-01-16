extends Area2D

@export var damage: int = 1
@onready var _animated_sprite = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionPolygon2D = $CollisionShape2D

var _recent_hits := {}
var _hit_cooldown := 0.2

const KNOCKBACK_POWER: float = 150
const KNOCKBACK_UP_MULTIPLIER: float = 0.5

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	_animated_sprite.visible = false
	# Auto-destroy after 0.4 seconds even if it misses
	await get_tree().create_timer(0.4).timeout
	queue_free()

func set_flip():
	scale.x = -1

func _on_body_entered(body: Node2D) -> void:
	if body == null:
		return
	if _recent_hits.has(body):
		return
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			var knockback_direction: Vector2 = (body.global_position - global_position).normalized()
			knockback_direction.y -= KNOCKBACK_UP_MULTIPLIER
			
			var knockback_vector: Vector2 = knockback_direction.normalized() * KNOCKBACK_POWER
			body.take_damage(damage, knockback_vector)
			
			_recent_hits[body] = true # Registering hit
			
			# Disabling the attack hit-box!
			if collision_shape_2d:
				collision_shape_2d.set_deferred("disabled", true)
				await get_tree().create_timer(_hit_cooldown).timeout
			
			_recent_hits.erase(body)
