extends CharacterBody2D

const speed = 60

var direction = 1
var health = 5
var max_health = 5
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# State enumeration
enum State {
	IDLE,
	ATTACKING
}

var state = State.IDLE
var attack_cooldown = 1.0 # seconds
var can_attack = true

# Respawn variables
var initial_position: Vector2
const RESPAWN_TIME: float = 5.0 #seconds

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var damage_area: Area2D = $DamageArea
@onready var attack_timer: Timer = $AttackTimer
@onready var respawn_timer: Timer = $RespawnTimer
@onready var explosion_sound: AudioStreamPlayer2D = $ExplosionSound


var health_bar: HealthBar

func _ready() -> void:
	add_to_group("enemies")
	initial_position = global_position
	
	respawn_timer.wait_time = RESPAWN_TIME
	respawn_timer.one_shot = true
	respawn_timer.connect("timeout", Callable(self, "_on_respawn_timer_timeout"))
	
	damage_area.connect("body_entered", Callable(self, "_on_damage_area_body_entered"))
	
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	attack_timer.connect("timeout", Callable(self, "_on_attack_timer_timeout"))
	
	# Create and attach health bar above the slime
	health_bar = HealthBar.new()
	health_bar.position = Vector2(0, -16)
	health_bar.set_max_value(max_health)
	health_bar.set_value(health)
	add_child(health_bar)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
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

func _on_damage_area_body_entered(body):
	print("DamageArea triggered by: ", body.name)
	if body.is_in_group("Player") and can_attack:
		if body.has_method("take_damage"):
			state = State.ATTACKING
			can_attack = false
			var knockback = (body.global_position - global_position).normalized() * 200
			body.take_damage(1, knockback)
			attack_timer.start()

func take_damage(amount, knockback_vector: Vector2 = Vector2.ZERO):
	health -= amount
	if health_bar:
		health_bar.set_value(health)
	
	# Applying knockback if a vector is provided.
	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector
		
	if health <= 0:
		die_and_respawn() # Updated by new function
		
func die_and_respawn():
	set_physics_process(false)
	
	$AnimatedSprite2D.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	$DamageArea/CollisionShape2D.set_deferred("disabled",true)
	
	if health_bar:
		health_bar.set_value(0)
		health_bar.hide()
		
		respawn_timer.start()
		explosion_sound.play()

func _on_respawn_timer_timeout():
	health = max_health
	state = State.IDLE
	
	global_position = initial_position
	velocity = Vector2.ZERO
	
	set_physics_process(true)
	$AnimatedSprite2D.visible = true
	$CollisionShape2D.set_deferred("disabled", false)
	$DamageArea/CollisionShape2D.set_deferred("disabled", false)
	
	if health_bar:
		health_bar.set_value(health)
		health_bar.show()

func _on_attack_timer_timeout():
	state = State.IDLE
	can_attack = true
