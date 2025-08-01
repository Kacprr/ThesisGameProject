extends CanvasLayer

@onready var health_bar = $HealthBar

func update_health(value):
	health_bar.value = value


func _on_player_health_changed(health: Variant) -> void:
	update_health(health)
