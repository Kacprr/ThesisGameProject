extends Control

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/game.tscn") #main game scene

func _on_options_button_pressed():
	print("Options selected") # Can later link to options screen

func _on_exit_button_pressed():
	get_tree().quit()
