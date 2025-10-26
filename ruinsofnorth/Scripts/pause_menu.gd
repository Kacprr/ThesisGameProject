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

# This is called by pressing the Resume button OR the ESC key.
func resume_game():
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
	
	if options_button is Control:
		options_button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	get_tree().root.add_child(options_menu)
	queue_free() # Remove the Pause Menu

func _on_quit_button_pressed():
	get_tree().quit()
