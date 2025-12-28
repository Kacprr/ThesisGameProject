extends Control
#setup variables localy instead of constantly reffering to Global.
var coin_count = Globals.score
var coin_goal = Globals.goal_coin
var red_count = Globals.red_score
var red_goal = Globals.red_goal
#set conditions as variables to shorten code
var coin_goal_reached = coin_count >= coin_goal
var red_goal_reached = red_count >= red_goal

func _on_ready() -> void:
	#setting up labels
	$MenuContainer/CoinContainer/CoinCount.text = str(coin_count)
	$MenuContainer/CoinContainer/CoinTotal.text = str(coin_goal)
	$MenuContainer/RedCoinContainer/RedCount.text = str(red_count)
	$MenuContainer/RedCoinContainer/RedTotal.text = str(red_goal)
	#make sure all end screens are hidden
	$EndScreenAllCoinAllRed.hide()
	$EndScreenNoCoinNoRed.hide()
	$EndScreenAllCoinNoRed.hide()
	$EndScreenNoCoinAllRed.hide()
	#reveal sceens based on coin goal conditions
	if coin_goal_reached and red_goal_reached:
		$EndScreenAllCoinAllRed.show()
	elif coin_goal_reached and !(red_goal_reached):
		$EndScreenAllCoinNoRed.show()
	elif !(coin_goal_reached) and red_goal_reached:
		$EndScreenNoCoinAllRed.show()
	else:
		$EndScreenNoCoinNoRed.show()
#handle buttons on screen
func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
