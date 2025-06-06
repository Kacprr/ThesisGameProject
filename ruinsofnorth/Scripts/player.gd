extends CharacterBody2D

var SPEED = 130.0
const JUMP_VELOCITY = -300.0

#enumeration used to track the current state, makes it easier to play animations
enum PlayerState {
	IDLE,
	JUMP,
	DASH,
	RUN,
}

var current_State

var gravitiy = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_scene = preload("res://scenes/Attack.tscn")

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
	var offset = Vector2(20, 0)
	if animated_sprite.flip_h:
		offset.x *= -1
	
	attack.global_position = global_position + offset
	get_tree().current_scene.add_child(attack)


#After dash is complete reseting speed back to base speed and ending dash
func _on_dash_timer_timeout() -> void:
	current_State = PlayerState.IDLE
	SPEED = 130.0
