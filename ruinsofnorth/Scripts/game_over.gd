extends CanvasLayer

@onready var play_again_button: Button = $VBoxContainer/PlayAgainButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

const GAME_SCENE = "res://Scenes/game.tscn"
const MAIN_MENU_SCENE = "res://Scenes/main_menu.tscn"

func _ready():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_play_again_button_pressed():
	get_tree().paused = false
	queue_free()
	
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_quit_button_pressed():
	get_tree().paused = false
	queue_free()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
