extends CanvasLayer

@onready var new_game_button: Button = $VBoxContainer/NewGame
@onready var quit_button: Button = $VBoxContainer/QuitButton

const GAME_SCENE = "res://Scenes/game.tscn"
const MAIN_MENU_SCENE = "res://Scenes/main_menu.tscn"

func _ready():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Respawn Logic
	if Globals.checkpoint_active and Globals.score >= 3:
		var respawn_btn = Button.new()
		respawn_btn.text = "Respawn (3 Coins)"
		respawn_btn.add_theme_font_size_override("font_size", 24)
		respawn_btn.add_theme_font_override("font", load("res://Assets/fonts/PixelOperator8.ttf") )
		
		# Insert it before the Quit button (at index 1, since Play Again is 0)
		$VBoxContainer.add_child(respawn_btn)
		$VBoxContainer.move_child(respawn_btn, 1)
		
		respawn_btn.pressed.connect(_on_respawn_button_pressed)

func _on_new_game_pressed() -> void:
	Globals.reset_checkpoint()
	Globals.reset_stats() # Optional: also reset coins/health/etc for a fresh start
	Globals.respawning = false
	if Music:
		Music.reset_game_music()

	get_tree().paused = false
	queue_free()
	
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_quit_button_pressed():
	get_tree().paused = false
	queue_free()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func _on_respawn_button_pressed():
	# Deduct cost
	var new_score = Globals.score - 3
	Globals.coins_to_restore = new_score
	Globals.red_coins_to_restore = Globals.red_score
	Globals.respawning = true
	
	get_tree().paused = false
	queue_free()
	get_tree().change_scene_to_file(GAME_SCENE)
