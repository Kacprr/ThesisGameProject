extends Area2D
class_name KnightTrap

@export var damage_amount: int = 1
@export var cooldown_time: float = 0.5
@export var knockback_power: float = 150.0
@export var isActive: bool = true

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	add_to_group("trap")
	cooldown_timer.wait_time = cooldown_time
	cooldown_timer.one_shot = true
	
	animated_sprite.play("idle")
	animated_sprite.animation_finished.connect(Callable(self, "_on_animation_finished"))

func _on_body_entered(body: Node2D):
	if body.is_in_group("Player") and isActive:
		deactivate_trap()
		animated_sprite.play("attack")
		
		if body.has_method("take_damage"):
			var knockback_direction = (body.global_position - global_position).normalized() * knockback_power
			body.take_damage(damage_amount, knockback_direction)
			
func deactivate_trap():
	isActive = false
	if collision_shape:
		collision_shape.set_deferred("disabled", true)

func _on_animation_finished():
	if animated_sprite.animation == "attack":
		animated_sprite.play("idle")
		cooldown_timer.start()

func _on_timer_timeout():
	activate_trap()

func activate_trap():
	isActive = true
	if collision_shape:
		collision_shape.set_deferred("disabled", false)
	animated_sprite.play("idle")
