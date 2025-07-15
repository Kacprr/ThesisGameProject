extends CharacterBody2D

const speed = 60

var direction = 1
var health = 1

# State enumeration
enum State {
	IDLE,
	ATTACKING
}


var state = State.IDLE
var attack_cooldown = 1.0 # seconds
var can_attack = true


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var damage_area: Area2D = $DamageArea

@onready var attack_timer: Timer = $AttackTimer

func _ready() -> void:
	add_to_group("enemies")
	damage_area.connect("body_entered", Callable(self, "_on_damage_area_body_entered"))
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	attack_timer.connect("timeout", Callable(self, "_on_attack_timer_timeout"))

func _physics_process(delta):
	if state == State.IDLE:
		if ray_cast_right.is_colliding():
			direction = -1
			animated_sprite.flip_h = true
		elif ray_cast_left.is_colliding():
			direction = 1
			animated_sprite.flip_h = false
		velocity.x = direction * speed
		move_and_slide()
		animated_sprite.play("idle")
	elif state == State.ATTACKING:
		velocity.x = 0
		move_and_slide()
		animated_sprite.play("attack")
		# Optionally, you can add logic to stop movement while attacking

func _on_damage_area_body_entered(body):
	print("DamageArea triggered by: ", body.name)
	if body.is_in_group("Player") and can_attack:
		if body.has_method("take_damage"):
			state = State.ATTACKING
			can_attack = false
			var knockback = (body.global_position - global_position).normalized() * 200
			body.take_damage(1, knockback)
			attack_timer.start()

func take_damage(amount):
	health -= amount
	if health <= 0:
		queue_free()

func _on_attack_timer_timeout():
	state = State.IDLE
	can_attack = true
