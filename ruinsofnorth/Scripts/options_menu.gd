extends Control

@onready var master_volume_slider: HSlider = $MenuContainer/AudioSection/MasterVolumeContainer/MasterVolumeSlider
@onready var master_volume_value: Label = $MenuContainer/AudioSection/MasterVolumeContainer/MasterVolumeValue
@onready var music_volume_slider: HSlider = $MenuContainer/AudioSection/MusicVolumeContainer/MusicVolumeSlider
@onready var music_volume_value: Label = $MenuContainer/AudioSection/MusicVolumeContainer/MusicVolumeValue
@onready var sfx_volume_slider: HSlider = $MenuContainer/AudioSection/SFXVolumeContainer/SFXVolumeSlider
@onready var sfx_volume_value: Label = $MenuContainer/AudioSection/SFXVolumeContainer/SFXVolumeValue
@onready var fullscreen_checkbox: CheckBox = $MenuContainer/GraphicsSection/FullscreenContainer/FullscreenCheckBox
@onready var back_button: Button = $MenuContainer/ButtonContainer/BackButton
@onready var reset_button: Button = $MenuContainer/ButtonContainer/ResetButton

# Audio bus indices
const MASTER_BUS = 0
const MUSIC_BUS = 1
const SFX_BUS = 2

func _ready():
	# Connect signals
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	fullscreen_checkbox.toggled.connect(_on_fullscreen_toggled)
	back_button.pressed.connect(_on_back_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	
	# Load saved settings
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
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_reset_pressed():
	# Reset audio to default
	AudioServer.set_bus_volume_db(MASTER_BUS, 0.0)
	AudioServer.set_bus_volume_db(MUSIC_BUS, 0.0)
	AudioServer.set_bus_volume_db(SFX_BUS, 0.0)
	
	# Reset graphics to default
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
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

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
