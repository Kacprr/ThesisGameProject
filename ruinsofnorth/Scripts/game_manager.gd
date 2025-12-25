extends Node

var score = 0

const PAUSE_MENU_SCENE =  preload("res://Scenes/pause_menu.tscn")
const END_SCREEN = preload("res://Scenes/EndScreen.tscn")

func _ready() -> void:
	if Music:
		Music.play()
	Globals.score = 0
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

func _on_flag_player_reached_flag() -> void:
	print("player Reached Flag")
	get_tree().change_scene_to_file("res://Scenes/EndScreen.tscn")
