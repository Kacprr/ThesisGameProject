extends Control

func _on_play_button_pressed():
	Globals.reset_checkpoint()
	get_tree().change_scene_to_file("res://Scenes/game.tscn") #main game scene

func _on_options_button_pressed():
	print("Opening options...")
	get_tree().change_scene_to_file("res://Scenes/options_menu.tscn")

func _on_exit_button_pressed():
	get_tree().quit()
