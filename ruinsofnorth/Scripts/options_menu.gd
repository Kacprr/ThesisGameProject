extends Control

@onready var master_volume_slider: HSlider = $MenuBackground/MenuContainer/TabContainer/Audio/MarginContainer/VBoxContainer/MasterVolumeContainer/MasterVolumeSlider
@onready var master_volume_value: Label = $MenuBackground/MenuContainer/TabContainer/Audio/MarginContainer/VBoxContainer/MasterVolumeContainer/MasterVolumeValue
@onready var music_volume_slider: HSlider = $MenuBackground/MenuContainer/TabContainer/Audio/MarginContainer/VBoxContainer/MusicVolumeContainer/MusicVolumeSlider
@onready var music_volume_value: Label = $MenuBackground/MenuContainer/TabContainer/Audio/MarginContainer/VBoxContainer/MusicVolumeContainer/MusicVolumeValue
@onready var sfx_volume_slider: HSlider = $MenuBackground/MenuContainer/TabContainer/Audio/MarginContainer/VBoxContainer/SFXVolumeContainer/SFXVolumeSlider
@onready var sfx_volume_value: Label = $MenuBackground/MenuContainer/TabContainer/Audio/MarginContainer/VBoxContainer/SFXVolumeContainer/SFXVolumeValue
@onready var fullscreen_checkbox: CheckBox = $MenuBackground/MenuContainer/TabContainer/Video/MarginContainer/VBoxContainer/FullscreenContainer/FullscreenCheckBox
@onready var back_button: Button = $MenuBackground/MenuContainer/ButtonContainer/BackButton
@onready var reset_button: Button = $MenuBackground/MenuContainer/ButtonContainer/ResetButton
@onready var action_list: VBoxContainer = $MenuBackground/MenuContainer/TabContainer/Controls/MarginContainer/ScrollContainer/ActionList


var is_overlay: bool = false

# Audio bus indices
const MASTER_BUS = 0
const MUSIC_BUS = 1
const SFX_BUS = 2

# Input actions to rebind
var action_items: Dictionary = {
	"move_left": "Left",
	"move_right": "Right",
	"jump": "Jump",
	"dash": "Dash",
	"attack": "Attack",
	"flip": "Flip Dimension"
}

var current_button: Button
var is_remapping: bool = false
var remapping_action: String = ""

const SETTINGS_FILE = "user://settings.cfg"

func _ready():
	# Connect signals
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	fullscreen_checkbox.toggled.connect(_on_fullscreen_toggled)
	back_button.pressed.connect(_on_back_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	
	_create_action_list()
	_load_settings()

func _load_settings():
	# Load audio settings
	var master_vol = AudioServer.get_bus_volume_db(MASTER_BUS)
	master_volume_slider.value = _db_to_percent(master_vol)
	_update_volume_display(master_volume_value, master_volume_slider.value)
	
	var music_vol = AudioServer.get_bus_volume_db(MUSIC_BUS)
	music_volume_slider.value = _db_to_percent(music_vol)
	_update_volume_display(music_volume_value, music_volume_slider.value)
	
	var sfx_vol = AudioServer.get_bus_volume_db(SFX_BUS)
	sfx_volume_slider.value = _db_to_percent(sfx_vol)
	_update_volume_display(sfx_volume_value, sfx_volume_slider.value)
	
	# Load graphics settings
	fullscreen_checkbox.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	
	_load_keybindings()

func _create_action_list():
	# Clear existing children if any
	for child in action_list.get_children():
		child.queue_free()
		
	for action in action_items:
		var label_text = action_items[action]
		
		var hbox = HBoxContainer.new()
		action_list.add_child(hbox)
		
		var label = Label.new()
		label.text = label_text
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(label)
		
		var button = Button.new()
		button.text = _get_input_label(action)
		button.custom_minimum_size = Vector2(100, 0)
		button.pressed.connect(_on_input_button_pressed.bind(button, action))
		hbox.add_child(button)

func _get_input_label(action: String) -> String:
	var events = InputMap.action_get_events(action)
	if events.size() > 0:
		# Just show the first one for the button label, or maybe combine them "W / Up"
		for event in events:
			if event is InputEventKey:
				return event.as_text().trim_suffix(" (Physical)")
		return events[0].as_text().trim_suffix(" (Physical)")
	return "Unbound"

func _on_input_button_pressed(button: Button, action: String):
	if is_remapping:
		return
	
	is_remapping = true
	current_button = button
	remapping_action = action
	button.text = "Press key..."

func _input(event):
	if is_remapping:
		if event.is_action_pressed("ui_cancel"):
			is_remapping = false
			current_button.text = _get_input_label(remapping_action)
			current_button = null
			remapping_action = ""
			accept_event()
			return

		if (
			event is InputEventKey or 
			event is InputEventMouseButton
		) and event.pressed:
			
			if event is InputEventMouseButton and event.double_click:
				return
			
			# When remapping in this simple UI, we assume replacing the primary key.
			# But to allow multiple bindings (users liking WASD + Arrows), we should be careful.
			# A simple rebind usually implies "Replace". 
			# IF we want to strictly fix the bug where "changing X breaks Y", we must ensure Y's multiple bindings are preserved during SAVE.
			# But for the CURRENT action being remapped, do we replace ALL or just ONE?
			# Standard simple game behavior: Erase All, Add New. 
			# BUT, if the user starts with WASD+Arrows, and changes "Jump" (Space), do they want to lose "Up Arrow"?
			# Probably yes, if they are customizing.
			# HOWEVER, the bug was "Changing Attack breaks Move Up". This implies Move Up (which wasn't touched) lost bindings.
			# This is because _save_keybindings() was only saving events[0] for EVERY action.
			
			InputMap.action_erase_events(remapping_action)
			InputMap.action_add_event(remapping_action, event)
			
			current_button.text = event.as_text().trim_suffix(" (Physical)")
			current_button = null
			is_remapping = false
			remapping_action = ""
			
			# Save remapping
			_save_keybindings()
			
			accept_event() # Stop propagation
	else:
		if event.is_action_pressed("ui_cancel"):
			_on_back_pressed()

func _save_keybindings():
	var config = ConfigFile.new()
	for action in action_items:
		var events = InputMap.action_get_events(action)
		config.set_value("input", action, events)
	config.save(SETTINGS_FILE)

func _load_keybindings():
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_FILE)
	if err == OK:
		for action in action_items:
			var events = config.get_value("input", action, [])
			
			if events is Array:
				if events.size() > 0:
					InputMap.action_erase_events(action)
					for event in events:
						InputMap.action_add_event(action, event)
			elif events != null:
				# Handle legacy single event save
				InputMap.action_erase_events(action)
				InputMap.action_add_event(action, events)
		
		# Update UI
		_create_action_list()

func _on_master_volume_changed(value: float):
	AudioServer.set_bus_volume_db(MASTER_BUS, _percent_to_db(value))
	_update_volume_display(master_volume_value, value)

func _on_music_volume_changed(value: float):
	AudioServer.set_bus_volume_db(MUSIC_BUS, _percent_to_db(value))
	_update_volume_display(music_volume_value, value)

func _on_sfx_volume_changed(value: float):
	AudioServer.set_bus_volume_db(SFX_BUS, _percent_to_db(value))
	_update_volume_display(sfx_volume_value, value)

func _on_fullscreen_toggled(enabled: bool):
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_back_pressed():
	if is_remapping:
		is_remapping = false
		current_button.text = _get_input_label(remapping_action)
		current_button = null
		remapping_action = ""
		return

	if is_overlay:
		queue_free()
	elif Globals.paused_var == true:
		get_tree().change_scene_to_file("res://Scenes/game.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_reset_pressed():
	# Reset audio to default
	AudioServer.set_bus_volume_db(MASTER_BUS, 0.0)
	AudioServer.set_bus_volume_db(MUSIC_BUS, 0.0)
	AudioServer.set_bus_volume_db(SFX_BUS, 0.0)
	
	# Reset graphics to default
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	# Reset bindings to default (Requires loading from project settings default, which is tricky at runtime without a backup)
	InputMap.load_from_project_settings()
	
	# Update UI
	_load_settings()

func _update_volume_display(label: Label, value: float):
	label.text = str(int(value)) + "%"

func _percent_to_db(percent: float) -> float:
	# Convert 0-100 to -60 to 0 dB range
	if percent <= 0:
		return -60.0
	return -60.0 + (percent / 100.0) * 60.0

func _db_to_percent(db: float) -> float:
	# Convert -60 to 0 dB to 0-100 range
	if db <= -60.0:
		return 0.0
	return ((db + 60.0) / 60.0) * 100.0
