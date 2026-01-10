extends AudioStreamPlayer

const MENU_MUSIC = preload("res://Assets/Tracks/Cuddle Clouds.wav")
const GAME_MUSIC = preload("res://Assets/music/time_for_adventure.mp3")
const PAUSE_MUSIC = preload("res://Assets/Tracks/Evening Harmony.wav")

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS # Ensure music plays/can be changed even when paused
	finished.connect(play)


func play_main_menu_music():
	if stream != MENU_MUSIC:
		stream = MENU_MUSIC
		volume_db = -5.0
		play()

func play_game_music():
	if stream != GAME_MUSIC:
		stream = GAME_MUSIC
		volume_db = -30.0
		play()

func play_pause_music():
	if stream != PAUSE_MUSIC:
		stream = PAUSE_MUSIC
		volume_db = -5.0
		play()
