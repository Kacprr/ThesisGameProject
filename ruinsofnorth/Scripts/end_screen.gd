extends Control
#setup variables localy instead of constantly reffering to Global.
var red_count = Globals.red_score
var red_goal = Globals.red_goal
#set conditions as variables to shorten code
var red_goal_reached = red_count >= red_goal

func _on_ready() -> void:
	#setting up labels
	$MenuContainer/RedCoinContainer/RedCount.text = str(red_count)
	$MenuContainer/RedCoinContainer/RedTotal.text = str(red_goal)
	#reveal sceens based on coin goal conditions
	if red_goal_reached:
		$Title.text = "You Found All The Red Coins\n\n   YOU WIN"
	else:
		$Title.text = "You Beat The Level\n\nNow Try To Find The Red Coins"
#handle buttons on screen
func _on_restart_button_pressed() -> void:
	Globals.reset_checkpoint()
	Globals.reset_stats()
	Globals.respawning = false
	if Music:
		Music.reset_game_music()
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Credits.tscn")
