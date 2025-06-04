extends CharacterBody2D

var SPEED = 130.0
const JUMP_VELOCITY = -300.0

#enumeration used to track the current state, makes it easier to play animations
enum PlayerState {
	IDLE,
	JUMP,
	DASH,
	RUN,
	ATTACK
}

var current_State

var gravitiy = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if !is_on_floor():
		current_State = PlayerState.JUMP
		SPEED = 130
		velocity += get_gravity() * delta

	# Get the input direction: -1, 0 ,1
	var direction := Input.get_axis("move_left", "move_right")

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		current_State = PlayerState.JUMP
		velocity.y = JUMP_VELOCITY

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
		
	# Handle attack input
	if Input.is_action_just_pressed("attack"):
		current_State = PlayerState.ATTACK
		$AttackTimer.start()
		$AttackArea.monitoring = true

	# Play Animations based on the current_state
	if is_on_floor():
		if current_State == PlayerState.IDLE:
			animated_sprite.play("idle")
		elif current_State == PlayerState.DASH:
			animated_sprite.play("dash")
		elif current_State == PlayerState.RUN:
			animated_sprite.play("run")
		elif current_State == PlayerState.ATTACK:
			animated_sprite.play("attack")
	elif current_State == PlayerState.JUMP:
		animated_sprite.play("jump")
	

#After dash is complete reseting speed back to base speed and ending dash
func _on_dash_timer_timeout() -> void:
	current_State = PlayerState.IDLE
	SPEED = 130.0

# This is basically signal to detect collision for attack sprite. 
# I opened up a new group called "enemies" for the slime and future mobs.
func _on_attack_area_body_entered(body: Node2D) -> void:
	if current_State == PlayerState.ATTACK and body.is_in_group("enemies"):
		body.free()  # or play a death animation
		print("attack connected")

func _on_attack_timer_timeout() -> void:
	current_State = PlayerState.IDLE
	$AttackArea.monitorable = false
