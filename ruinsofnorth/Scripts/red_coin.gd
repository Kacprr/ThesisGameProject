extends Area2D

@onready var game_manager: Node = %GameManager



func _on_body_entered(body: Node2D) -> void:
	game_manager.add_red_coin()


func _on_ready() -> void:
	add_to_group("Red_Coins")
