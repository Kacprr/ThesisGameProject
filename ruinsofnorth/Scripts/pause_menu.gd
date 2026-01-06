extends CanvasLayer

@onready var resume_button: Button = $VBoxContainer/ResumeButton
@onready var options_button: Button = $VBoxContainer/OptionsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton


const OPTIONS_SCENE = preload("res://Scenes/options_menu.tscn")
const MAIN_MENU_SCENE = preload("res://Scenes/main_menu.tscn")

func _ready():
	resume_button.pressed.connect(_on_resume_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	Globals.paused_var = false
	
	# Hud visibility
	var hud = get_tree().current_scene.get_node_or_null("HUD")
	if hud and hud.has_method("move_ui_for_pause"):
		hud.move_ui_for_pause(true)

# This is called by pressing the Resume button OR the ESC key.
func resume_game():
	var hud = get_tree().current_scene.get_node_or_null("HUD")
	if hud and hud.has_method("move_ui_for_pause"):
		hud.move_ui_for_pause(false)
		
	get_tree().paused = false
	queue_free()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and event.is_pressed():
		get_viewport().set_input_as_handled()
		resume_game()

func _on_resume_button_pressed():
	resume_game()

func _on_options_button_pressed():
	var options_menu = OPTIONS_SCENE.instantiate()
	options_menu.is_overlay = true
	add_child(options_menu)
	$VBoxContainer.visible = false
	options_menu.tree_exiting.connect(func(): $VBoxContainer.visible = true)

func _on_quit_button_pressed():
	get_tree().paused = false
	queue_free()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
