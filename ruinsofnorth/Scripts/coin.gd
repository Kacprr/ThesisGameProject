extends Area2D

@onready var game_manager: Node = %GameManager
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	if Globals.is_coin_collected(str(get_path())):
		return # Should be gone, but safety check
		
	Globals.register_coin_collected(str(get_path()))
	game_manager.add_point()
	animation_player.play("pickup")


func _on_ready() -> void:
	if Globals.is_coin_collected(str(get_path())):
		queue_free()
	add_to_group("Coins")
