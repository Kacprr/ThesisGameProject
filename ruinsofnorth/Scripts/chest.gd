extends Area2D

@onready var stat_collectible = preload("res://Scenes/stat_upgrade_collectible.tscn")
#"res://Scenes/healing_power_up.tscn"
#"res://Scenes/stat_upgrade_collectible.tscn"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("has_keys") and body.has_method("use_keys"):
		if body.has_keys():
			call_deferred("_open_chest", body)

func _open_chest(body: Node2D) -> void:
	var powerup = stat_collectible.instantiate()
	powerup.global_position = global_position
	get_tree().current_scene.add_child(powerup)
	powerup.activate_loot()
	
	body.use_keys()
	queue_free()
