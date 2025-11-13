extends CharacterBody2D

@export var speed: int = 120
@export var health: int = 100

var is_healing_over_time = false
var can_attack = true
var is_dead = false
var is_invulnerable = false
var has_air_dashed: bool = false

var jumps_left: int = 1 # Start with 1 extra jump (for a total of 2)
var direction_var = 0
var hot_heal_amount = 0

const ATTACK_COOLDOWN = 0.7 # cooldown time in sec
const JUMP_VELOCITY = -250.0 # Nerfed due to new dash feature!
const GAME_OVER_SCENE = preload("res://Scenes/game_over.tscn")
const HEALING_EFFECT_SCENE = preload("res://Scenes/healing_effect.tscn")

const WALL_SLIDE_SPEED = 30.0
const WALL_CLING_COST_PER_SEC = 20.0
const WALL_JUMP_FORCE = 300.0 # Horizontal force for wall jump

var max_stamina = 100
var current_stamina: float = max_stamina
var dash_cost = 25
var stamina_regen = 10.0

enum PlayerState {
	IDLE,
	JUMP,
	DASH,
	RUN,
	STUNNED,
	ATTACK,
	WALL_CLING,
}

var current_State

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

signal health_changed(health)
signal stamina_changed(stamina)
signal max_health_changed(new_max_health)
signal max_stamina_changed(new_max_stamina)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_scene = preload("res://scenes/Attack.tscn")

@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var dash_sound: AudioStreamPlayer2D = $DashSound
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer
@onready var knockback_timer: Timer = $KnockbackTimer
@onready var hot_tick_timer: Timer = $HotTickTimer

func _ready():
	add_to_group("Player")
	attack_cooldown_timer.wait_time = ATTACK_COOLDOWN
	attack_cooldown_timer.one_shot = true
	animated_sprite.animation_finished.connect(_on_attack_animation_finished)

func _physics_process(_delta: float) -> void:
	const DASH_SPEED = 130.0
	
	# New: Full 4-Way Direction Vectors
	var direction_x = Input.get_axis("move_left", "move_right")
	var direction_y = Input.get_axis("move_up", "move_down")
	var direction: float = direction_x
	if direction != 0:
		direction_var = sign(direction)
	
	# Calculates the normalized vector (up, down, diagonal)
	var dash_vector = Vector2(direction_x, direction_y).normalized()
	var is_dash_input = dash_vector.length_squared() > 0.01 # True if ANY direction key is held


	# -- 1. CORE STATE LOCKS & GRAVITY --
	if current_State == PlayerState.STUNNED:
		velocity.y += gravity * _delta
		move_and_slide()
		return

	# Add the gravity.
	if !is_on_floor():
		if current_State != PlayerState.DASH and current_State != PlayerState.WALL_CLING:
				current_State = PlayerState.JUMP
		if current_State != PlayerState.DASH:
			velocity.y += gravity * _delta

	if current_stamina < max_stamina:
		current_stamina = min(current_stamina + stamina_regen * _delta, max_stamina)
		emit_signal("stamina_changed", current_stamina) # Stamina signal


	# -- 2. WALL CLING LOGIC --
	var wall_cling_input = is_on_wall() and direction_x != 0 and !is_on_floor()
	
	if wall_cling_input and current_State != PlayerState.DASH:
		if current_stamina > 0:
			current_State = PlayerState.WALL_CLING
			# Consume stamina
			var cost = WALL_CLING_COST_PER_SEC * _delta
			current_stamina = max(current_stamina - cost, 0.0)
			emit_signal("stamina_changed", current_stamina)
			
			if current_stamina <= 0.0:
				current_State = PlayerState.JUMP
				
			# Slide Physics
		if current_State == PlayerState.WALL_CLING:
			velocity.y = min(velocity.y, WALL_SLIDE_SPEED)
			if (Input.is_action_just_pressed("jump")):
				velocity.y = JUMP_VELOCITY
				current_State = PlayerState.JUMP
				current_stamina -= 10
				jump_sound.play()
			animated_sprite.flip_h = (direction_x < 0)
		else:
			current_State = PlayerState.JUMP # Fall if stamina is zero
			
	elif current_State == PlayerState.WALL_CLING and (!wall_cling_input or is_on_floor()):
		current_State = PlayerState.JUMP # Stop cling if input or wall is lost
		
	# -- 3. DASH LOGIC --
	if Input.is_action_just_pressed("dash") and current_stamina >= dash_cost and current_State != PlayerState.DASH and is_dash_input:
		var is_ground_dash_available = is_on_floor()
		var is_air_dash_available = !is_on_floor() and !has_air_dashed
		
		if is_ground_dash_available or is_air_dash_available:
			current_stamina -= dash_cost
			emit_signal("stamina_changed", current_stamina)
			
			if is_air_dash_available:
				has_air_dashed = true
		
			current_State = PlayerState.DASH
			$DashTimer.start()
			velocity = dash_vector * DASH_SPEED
			dash_sound.play()
			move_and_slide()
			return

	# --- 4. JUMP/DOUBLE JUMP LOGIC ---
	if is_on_floor():
		jumps_left = 1
		has_air_dashed = false
		if current_State != PlayerState.DASH and current_State != PlayerState.ATTACK:
			current_State = PlayerState.IDLE #Resets state when landing.
	
	# Horizontal Movement Application (Only if NOT DASHING or CLINGING)
	if current_State != PlayerState.DASH and current_State != PlayerState.WALL_CLING:
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

		# Handle short jump
		else:
			if Input.is_action_just_released("jump"):
				current_State = PlayerState.JUMP
				velocity.y *= 0.5

		# Flip the Sprite
		if direction > 0:
			animated_sprite.flip_h = false
		elif direction < 0:
			animated_sprite.flip_h = true
		elif direction == 0:
			if direction_var > 0:
				animated_sprite.flip_h = false
			elif direction_var < 0:
				animated_sprite.flip_h = true
	
		# Apply Horizontal Movement
		if direction_x:
			if is_on_floor() and current_State != PlayerState.ATTACK:
				current_State = PlayerState.RUN
			velocity.x = direction * speed
		else:
			if current_State != PlayerState.ATTACK:
				current_State = PlayerState.IDLE
				velocity.x = move_toward(velocity.x, 0, speed)
	move_and_slide()

	# Play Animations based on the current_state
	if animated_sprite.is_playing() and animated_sprite.animation == "attack":
		return
	elif current_State == PlayerState.DASH:
		animated_sprite.play("dash")
	elif current_State == PlayerState.WALL_CLING:
		animated_sprite.play("jump") # Temporary using the jump animation.
	elif !is_on_floor():
		animated_sprite.play("jump")
	elif is_on_floor():
		if current_State == PlayerState.IDLE:
			animated_sprite.play("idle")
		elif current_State == PlayerState.RUN:
			animated_sprite.play("run")

func _unhandled_input(event):
	if is_dead:
		return
	
	if event.is_action_pressed("attack") and can_attack:
		spawn_attack()

func spawn_attack():
	current_State = PlayerState.ATTACK
	animated_sprite.play("attack")
	
	can_attack = false
	attack_cooldown_timer.start()
	
	var attack = attack_scene.instantiate()
	# Flip position based on facing direction
	var offset = Vector2(10, -5)
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
	set_process_input(false)
	set_physics_process(false)
	animated_sprite.stop()
	animated_sprite.play("die")
	
	$CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(1.0).timeout
	
	var game_over_screen = GAME_OVER_SCENE.instantiate()
	get_tree().root.add_child(game_over_screen)

func take_damage(amount, _knockback = Vector2.ZERO):
	if is_invulnerable:
		return
	
	health -= amount
	emit_signal("health_changed", health)
	
	hurt_sound.play()

	is_invulnerable = true
	modulate = Color(1, 0.5, 0.5) # Red tint
	$InvulnTimer.start()
	
	apply_knockback(0.15)

	if health <= 0:
		is_dead = true
		current_State = PlayerState.IDLE
		die()
		
func apply_vertical_velocity(force: float):
	velocity.y = force
	current_State = PlayerState.JUMP

func apply_knockback(stun_duration: float):
	current_State = PlayerState.STUNNED
	velocity.y = -300
	if direction_var == -1:
		velocity.x += 200
	elif direction_var == 1:
		velocity.x -= 200
	knockback_timer.wait_time = stun_duration
	knockback_timer.start()

func heal(amount: int):
	health = min(health + amount, health)
	show_instant_heal_effect(0.5)
	emit_signal("health_changed", health)

func show_instant_heal_effect(duration: float):
	var instant_visual = HEALING_EFFECT_SCENE.instantiate()
	add_child(instant_visual)
	instant_visual.position = Vector2(0, -25)
	instant_visual.name = "InstantVisual" + str(randf())
	
	if instant_visual.has_method("start_animation"):
		instant_visual.start_animation(duration)
	
func start_heal_over_time(heal_amount: int, duration: float):
	if is_healing_over_time:
		return
	is_healing_over_time = true
	hot_heal_amount = heal_amount
	
	var healing_effect = HEALING_EFFECT_SCENE.instantiate()
	add_child(healing_effect)
	healing_effect.position = Vector2(0, -25)
	healing_effect.name = "HoTVisual"
	healing_effect.start_animation()
	
	if healing_effect.has_method("start_animation"):
		healing_effect.start_animation(duration)
	
	hot_tick_timer.wait_time = 1.0
	hot_tick_timer.start()
	
	await get_tree().create_timer(duration).timeout
	stop_heal_over_time()
	
func stop_heal_over_time():
	is_healing_over_time = false
	hot_heal_amount = 0
	hot_tick_timer.stop()
	
	var visual_effect = get_node_or_null("HoTVisual")
	if is_instance_valid(visual_effect):
		visual_effect.queue_free()
	
	if current_State == PlayerState.IDLE:
		animated_sprite.play("idle")
	elif current_State == PlayerState.RUN:
		animated_sprite.play("run")
		
func upgrade_max_health(bonus: int):
	var old_current_health = health
	var new_max = old_current_health + bonus
	health = new_max
	emit_signal("max_health_changed", new_max)
	emit_signal("health_changed", new_max)

func upgrade_max_stamina(bonus: int):
	var new_max = max_stamina + bonus
	max_stamina = new_max
	current_stamina = float(new_max)
	emit_signal("max_stamina_changed", new_max)
	emit_signal("stamina_changed", current_stamina)

func _on_attack_animation_finished():
	if animated_sprite.animation == "attack":
		current_State = PlayerState.IDLE

func _on_hot_tick_timer_timeout() -> void:
	if is_healing_over_time:
		heal(hot_heal_amount)
		hot_tick_timer.start()

func _on_invuln_timer_timeout() -> void:
	is_invulnerable = false
	modulate = Color(1, 1, 1) # Reset tint
	
func _on_knockback_timer_timeout() -> void:
	current_State = PlayerState.IDLE
