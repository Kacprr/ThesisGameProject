extends Node

var score = 0

const PAUSE_MENU_SCENE =  preload("res://Scenes/pause_menu.tscn")
const END_SCREEN = preload("res://Scenes/EndScreen.tscn")

func _ready() -> void:
	if Music:
		Music.play()
	Globals.score = 0
	Globals.red_score = 0
	Globals.goal_coin = get_tree().get_nodes_in_group("Coins").size()
	Globals.red_goal = get_tree().get_nodes_in_group("Red_Coins").size()
	call_deferred("_init_hud")

func _init_hud() -> void:
	var hud := get_node_or_null("../HUD")
	if hud:
		hud.update_score(score)
		if hud.has_method("update_red_score"):
			hud.update_red_score(Globals.red_score)
		var player := get_node_or_null("../Player")
		if player:
			var player_health = player.get("health")
			if typeof(player_health) == TYPE_INT or typeof(player_health) == TYPE_FLOAT:
				var player_health_int := int(player_health)
				if hud.has_method("set_max_health"):
					hud.set_max_health(player_health_int)
					hud.update_health(player_health_int)
			
			var player_max_stamina = player.get("max_stamina")
			var player_current_stamina = player.get("current_stamina")
			if player_max_stamina != null:
				var max_stamina_int := int(player_max_stamina)
				if hud.has_method("set_max_stamina"):
					hud.set_max_stamina(max_stamina_int)
			if player_current_stamina != null:
				if hud.has_method("update_stamina"):
					hud.update_stamina(float(player_current_stamina))
					
func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel") and not get_tree().paused:
		get_tree().paused = true # Pause the game
		Globals.paused_var = true
	if Globals.paused_var == true:
		pause_menu_change()

func pause_menu_change():
	var pause_menu = PAUSE_MENU_SCENE.instantiate()
	if pause_menu is Control:
		pause_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(pause_menu)

func add_point():
	score += 1
	Globals.score += 1
	var hud := get_node_or_null("../HUD")
	if hud:
		hud.update_score(score)

func add_red_coin():
	Globals.red_score += 1
	var hud := get_node_or_null("../HUD")
	if hud:
		hud.update_red_score(Globals.red_score)

func _on_flag_player_reached_flag() -> void:
	print("player Reached Flag")
	get_tree().change_scene_to_file("res://Scenes/EndScreen.tscn")
