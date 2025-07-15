extends CharacterBody2D

# State enumeration
enum State {
	IDLE,
	ATTACKING
}

var state = State.IDLE
var attack_cooldown = 1.0 # seconds
var can_attack = true

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_area: Area2D = $DamageArea
@onready var attack_timer: Timer = Timer.new()

func _ready():
	add_to_group("enemies")
	damage_area.connect("body_entered", Callable(self, "_on_damage_area_body_entered"))
	add_child(attack_timer)
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	attack_timer.connect("timeout", Callable(self, "_on_attack_timer_timeout"))

func _physics_process(delta):
	if state == State.IDLE:
		# Add movement logic here if desired
		animated_sprite.play("idle")
	elif state == State.ATTACKING:
		animated_sprite.play("attack")
		# Optionally, stop movement while attacking

func _on_damage_area_body_entered(body):
	if body.name == "Player" and can_attack:
		if body.has_method("take_damage"):
			state = State.ATTACKING
			can_attack = false
			body.take_damage(1)
			attack_timer.start()

func _on_attack_timer_timeout():
	state = State.IDLE
	can_attack = true
