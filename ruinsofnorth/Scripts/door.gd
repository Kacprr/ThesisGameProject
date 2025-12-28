extends Area2D

@export var destination_door: Area2D
@export var spawn_offset: Vector2 = Vector2.ZERO

var player_in_range = false
var player_body: CharacterBody2D = null

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


var is_teleporting = false
@export var teleport_delay: float = 0.5

func _process(_delta):
	if player_in_range and Input.is_physical_key_pressed(KEY_E) and not is_teleporting:
		if destination_door:
			is_teleporting = true
			await get_tree().create_timer(teleport_delay).timeout
			teleport_player()
			is_teleporting = false
		else:
			print("Door: No destination set!")

func _on_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true
		player_body = body

func _on_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false
		player_body = null

func teleport_player():
	if player_body:
		var target_pos = destination_door.global_position + destination_door.spawn_offset
		player_body.global_position = target_pos
