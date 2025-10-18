extends CharacterBody2D

var SPEED = 130.0
const JUMP_VELOCITY = -300.0
var health = 5
var is_invulnerable = false
var jumps_left: int = 1 # Start with 1 extra jump (for a total of 2)

#enumeration used to track the current state, makes it easier to play animations
enum PlayerState {
	IDLE,
	JUMP,
	DASH,
	RUN,
}

var current_State

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

signal health_changed(health)
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_scene = preload("res://scenes/Attack.tscn")


func _ready():
	add_to_group("Player")


func _physics_process(_delta: float) -> void:
	# Add the gravity.
	if !is_on_floor():
		current_State = PlayerState.JUMP
		SPEED = 130
		velocity.y += gravity * _delta
	# --- JUMP/DOUBLE JUMP LOGIC ---
	if is_on_floor():
		jumps_left = 1
		current_State = PlayerState.IDLE #Resets state when landing.


	# Get the input direction: -1, 0 ,1
	var direction := Input.get_axis("move_left", "move_right")

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		current_State = PlayerState.JUMP
		velocity.y = JUMP_VELOCITY
		
	# Handle double-jump
	elif Input.is_action_just_pressed("jump") and jumps_left > 0:
		current_State = PlayerState.JUMP
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1 #Decrement the counter!
	

	#Handle dash
	if Input.is_action_just_pressed("dash") and is_on_floor() and current_State != PlayerState.DASH and direction:
		current_State = PlayerState.DASH
		var active_direction = direction
		$DashTimer.start()
		direction = active_direction
		SPEED *= 1.5
		velocity.x = direction * SPEED
		
		# Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
		# Apply Movement
	if current_State != PlayerState.DASH:
		if direction:
			if is_on_floor():
				current_State = PlayerState.RUN
			velocity.x = direction * SPEED
		else:
			current_State = PlayerState.IDLE
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
		

	# Play Animations based on the current_state
	if is_on_floor():
		if current_State == PlayerState.IDLE:
			animated_sprite.play("idle")
		elif current_State == PlayerState.DASH:
			animated_sprite.play("dash")
		elif current_State == PlayerState.RUN:
			animated_sprite.play("run")
	elif current_State == PlayerState.JUMP:
		animated_sprite.play("jump")
	

func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		spawn_attack()

func spawn_attack():
	var attack = attack_scene.instantiate()
	# Flip position based on facing direction
	var offset = Vector2(15, -5)
	if animated_sprite.flip_h:
		offset.x *= -1
		attack.set_flip()
	
	attack.global_position = global_position + offset
	get_tree().current_scene.add_child(attack)


#After dash is complete reseting speed back to base speed and ending dash
func _on_dash_timer_timeout() -> void:
	current_State = PlayerState.IDLE
	SPEED = 130.0

func die():
	print("You died!")
	get_tree().call_deferred("reload_current_scene")


func take_damage(amount, knockback = Vector2.ZERO):
	if is_invulnerable:
		return
	
	health -= amount
	emit_signal("health_changed", health)
	print("Player took damage. Health: ", health)

	is_invulnerable = true
	modulate = Color(1, 0.5, 0.5) # Red tint
	$InvulnTimer.start()

	# Apply knockback
	if knockback != Vector2.ZERO:
		velocity += knockback

	if health <= 0:
		die()


func _on_invuln_timer_timeout() -> void:
	is_invulnerable = false
	modulate = Color(1, 1, 1) # Reset tint
	
