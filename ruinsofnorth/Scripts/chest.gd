extends Area2D

@export var id: String = ""
@onready var stat_collectible = preload("res://Scenes/stat_upgrade_collectible.tscn")
@onready var animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	if id == "":
		id = str(global_position)
		
	if Globals.is_chest_opened(id):
		animated_sprite.play("open")
		set_deferred("monitoring", false)
	else:
		animated_sprite.play("closed")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("has_keys") and body.has_method("use_keys"):
		if body.has_keys() and !Globals.is_chest_opened(id):
			call_deferred("_open_chest", body)

func _open_chest(body: Node2D) -> void:
	Globals.register_chest_opened(id)
	body.use_keys()
	animated_sprite.play("open")
	set_deferred("monitoring", false)
	var powerup = stat_collectible.instantiate()
	powerup.global_position = global_position
	powerup.global_position.y -= 20 
	get_tree().current_scene.add_child(powerup)
	powerup.activate_loot()
