extends Control

func _ready():
	if Music:
		Music.play_main_menu_music()

func _on_play_button_pressed():
	Globals.reset_checkpoint()
	Globals.reset_stats()
	if Music:
		Music.reset_game_music()
	get_tree().change_scene_to_file("res://Scenes/game.tscn") #main game scene

func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/options_menu.tscn")

func _on_credits_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Credits.tscn")

func _on_exit_button_pressed():
	get_tree().quit()
