extends CharacterBody2D

@export var SPEED: int = 120
@export var health: int = 10

var is_invulnerable = false
var can_attack = true
var jumps_left: int = 1 # Start with 1 extra jump (for a total of 2)
var direction_var = 0

const ATTACK_COOLDOWN = 0.4 # cooldown time in sec
const JUMP_VELOCITY = -300.0

enum PlayerState {
	IDLE,
	JUMP,
	DASH,
	RUN,
	STUNNED,
}

var current_State

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

signal health_changed(health)
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_scene = preload("res://scenes/Attack.tscn")

@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var dash_sound: AudioStreamPlayer2D = $DashSound
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer
@onready var knockback_timer: Timer = $KnockbackTimer


func _ready():
	add_to_group("Player")
	attack_cooldown_timer.wait_time = ATTACK_COOLDOWN
	attack_cooldown_timer.one_shot = true


func _physics_process(_delta: float) -> void:
	const DASH_SPEED = 200.0
	
	if current_State == PlayerState.STUNNED:
		velocity.y += gravity * _delta
		move_and_slide()
		return
	
	# Add the gravity.
	if !is_on_floor():
		if current_State != PlayerState.DASH:
			current_State = PlayerState.JUMP
		velocity.y += gravity * _delta
	# --- JUMP/DOUBLE JUMP LOGIC ---
	if is_on_floor():
		jumps_left = 1
		if current_State != PlayerState.DASH:
			current_State = PlayerState.IDLE #Resets state when landing.


	# Get the input direction: -1, 0 ,1
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0:
		direction_var = direction

	# Handle jump.
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			current_State = PlayerState.JUMP
			velocity.y = JUMP_VELOCITY
			jump_sound.play()

	# Handle double-jump
	elif Input.is_action_just_pressed("jump") and jumps_left > 0:
		current_State = PlayerState.JUMP
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1  #Decrement the counter!
		jump_sound.play()

	#handle short jump
	else:
		if Input.is_action_just_released("jump"):
			current_State = PlayerState.JUMP
			velocity.y *= 0.5

	#Handle dash
	if Input.is_action_just_pressed("dash") and is_on_floor() and current_State != PlayerState.DASH and direction:
		current_State = PlayerState.DASH
		var active_direction = direction
		$DashTimer.start()
		direction = active_direction
		velocity.x = direction * DASH_SPEED
		dash_sound.play()
		
	if current_State != PlayerState.DASH:
		# Flip the Sprite
		if direction > 0:
			animated_sprite.flip_h = false
		elif direction < 0:
			animated_sprite.flip_h = true
	
		# Apply Movement
		if direction:
			if is_on_floor():
				current_State = PlayerState.RUN
			velocity.x = direction * SPEED
		else:
			current_State = PlayerState.IDLE
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
		

	# Play Animations based on the current_state
	if current_State == PlayerState.DASH:
		animated_sprite.play("dash")
	elif !is_on_floor():
		animated_sprite.play("jump")
	elif is_on_floor():
		if current_State == PlayerState.IDLE:
			animated_sprite.play("idle")
		elif current_State == PlayerState.RUN:
			animated_sprite.play("run")

func _unhandled_input(event):
	if event.is_action_pressed("attack") and can_attack:
		spawn_attack()

func spawn_attack():
	can_attack = false
	attack_cooldown_timer.start()
	
	var attack = attack_scene.instantiate()
	# Flip position based on facing direction
	var offset = Vector2(15, -5)
	if animated_sprite.flip_h:
		offset.x *= -1
		attack.set_flip()
	
	attack.global_position = global_position + offset
	get_tree().current_scene.add_child(attack)


func _on_attack_cooldown_timer_timeout():
	can_attack = true

#After dash is complete reseting speed back to base speed and ending dash
func _on_dash_timer_timeout() -> void:
	current_State = PlayerState.IDLE

func die():
	get_tree().call_deferred("reload_current_scene")


func take_damage(amount, knockback = Vector2.ZERO):
	if is_invulnerable:
		return
	
	health -= amount
	emit_signal("health_changed", health)
	
	hurt_sound.play()

	is_invulnerable = true
	modulate = Color(1, 0.5, 0.5) # Red tint
	$InvulnTimer.start()

	# Apply knockback
	if knockback != Vector2.ZERO:
		apply_knockback(knockback, 0.15)

	if health <= 0:
		die()
		
func apply_vertical_velocity(force: float):
	velocity.y = force
	current_State = PlayerState.JUMP

func apply_knockback(knocback_vector: Vector2, stun_duration: float):
	current_State = PlayerState.STUNNED
	velocity = knocback_vector
	velocity.y = knocback_vector.y * 1.5
	if direction_var == -1:
		velocity.x += 100
	elif direction_var == 1:
		velocity.x -= 100
	knockback_timer.wait_time = stun_duration
	knockback_timer.start()

func heal(amount: int):
	health = min(health + amount, 10)
	emit_signal("health_changed", health)

func _on_invuln_timer_timeout() -> void:
	is_invulnerable = false
	modulate = Color(1, 1, 1) # Reset tint
	
func _on_knockback_timer_timeout() -> void:
	current_State = PlayerState.IDLE
