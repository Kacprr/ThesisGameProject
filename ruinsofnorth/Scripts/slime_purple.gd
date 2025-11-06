extends CharacterBody2D

const speed = 80
const PATROL_BOUNCE_FORCE = -100.0
const BOUNCE_FORCE = -1000.0
const KNOCKBACK_DECEL = 500

# Respawn var
var initial_position: Vector2
const RESPAWN_TIME: float = 5.0 #seconds

@export var health: int = 5
@export var attack_cooldown = 0.5


var max_health = 5
var direction
var is_knocked_back = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum State {
	IDLE,
	ATTACKING
}

var state = State.IDLE
var can_attack = true
var health_bar: HealthBar

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var damage_area: Area2D = $DamageArea
@onready var attack_timer: Timer = $AttackTimer
@onready var respawn_timer: Timer = $RespawnTimer
@onready var explosion_sound: AudioStreamPlayer2D = $ExplosionSound

func _ready() -> void:
	direction = 1
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
	
	if is_knocked_back:
		velocity.x = move_toward(velocity.x, 0, KNOCKBACK_DECEL * delta)
		
	if is_on_floor():
		if abs(velocity.x) < 1.0:
			is_knocked_back = false
			velocity.x = 0
			state = State.IDLE
			
		# NEW: Apply constant patrol bounce on landing
		if not is_knocked_back and state == State.IDLE:
			velocity.y = PATROL_BOUNCE_FORCE
	
	if state == State.IDLE:
		if not is_knocked_back:
			if ray_cast_right.is_colliding():
				direction = -1
				animated_sprite.flip_h = true
			elif ray_cast_left.is_colliding():
				direction = 1
				animated_sprite.flip_h = false
				
			velocity.x = direction * speed
			animated_sprite.play("idle")
		
	elif state == State.ATTACKING:
		velocity.x = 0
		animated_sprite.play("attack")
		
	move_and_slide()
	
func _on_damage_area_body_entered(body):
	if body.is_in_group("Player") and can_attack:
		if body.has_method("take_damage"):
			state = State.ATTACKING
			can_attack = false
			body.take_damage(12)
			attack_timer.start()

func take_damage(amount, knockback_vector: Vector2 = Vector2.ZERO):
	health -= amount
	if health_bar:
		health_bar.set_value(health)
	
	# Applying knockback if a vector is provided.
	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector
		is_knocked_back = true
		
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
	is_knocked_back = false # Resets on respawn.
	
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
	var damage_area_nodes = damage_area.get_overlapping_bodies()
	var player_in_range = false
	var player_node = null
	
	for body in damage_area_nodes:
		if body.is_in_group("Player"):
			player_in_range = true
			player_node = body
			break
	if player_in_range:
		if player_node.has_method("take_damage"):
			player_node.take_damage(1)
			attack_timer.start()
	else:
		state = State.IDLE
		can_attack = true


func _on_bounce_area_body_entered(body: Node2D):
	if body.is_in_group("Player") and body.has_method("apply_vertical_velocity"):
		body.apply_vertical_velocity(BOUNCE_FORCE)
		body.take_damage(1, Vector2.ZERO)
