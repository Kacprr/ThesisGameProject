extends Area2D

@onready var game_manager: Node = %GameManager

func _on_ready() -> void:
	if Globals.is_coin_collected(str(get_path())):
		queue_free()
	add_to_group("Red_Coins")
	$AnimatedSprite2D.play("idle")

func _on_body_entered(_body: Node2D) -> void:
	if Globals.is_coin_collected(str(get_path())):
		return

	Globals.register_coin_collected(str(get_path()))
	game_manager.add_red_coin()
	$PickupSound.play()
	$CollisionPolygon2D.set_deferred("disabled", true)
	$AnimatedSprite2D.visible = false
	await $PickupSound.finished
	queue_free()
