extends Node

var score = 0

func _ready() -> void:
	call_deferred("_init_hud")

func _init_hud() -> void:
	var hud := get_node_or_null("../HUD")
	if hud:
		hud.update_score(score)
		var player := get_node_or_null("../Player")
		if player:
			var h = player.get("health")
			if typeof(h) == TYPE_INT or typeof(h) == TYPE_FLOAT:
				var ih := int(h)
				if hud.has_method("set_max_health"):
					hud.set_max_health(ih)
					hud.update_health(ih)

func add_point():
	score += 1
	var hud := get_node_or_null("../HUD")
	if hud:
		hud.update_score(score)
