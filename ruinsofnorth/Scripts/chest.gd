extends Area2D

@export var id: String = ""
@onready var stat_collectible = preload("res://Scenes/stat_upgrade_collectible.tscn")
@onready var animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if id == "":
		# Auto-generate ID based on position if not set manually
		id = str(global_position)
		
	if Globals.is_chest_opened(id):
		# Already opened
		animated_sprite.play("open")
		set_deferred("monitoring", false)
	else:
		animated_sprite.play("closed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("has_keys") and body.has_method("use_keys"):
		if body.has_keys() and !Globals.is_chest_opened(id):
			call_deferred("_open_chest", body)

func _open_chest(body: Node2D) -> void:
	Globals.register_chest_opened(id)
	body.use_keys()
	
	animated_sprite.play("open")
	
	# Disable the chest so it can't be opened again
	set_deferred("monitoring", false)
	
	var powerup = stat_collectible.instantiate()
	powerup.global_position = global_position
	# Offset logic could be added here if needed to make loot pop out visibly
	powerup.global_position.y -= 20 
	get_tree().current_scene.add_child(powerup)
	powerup.activate_loot()
