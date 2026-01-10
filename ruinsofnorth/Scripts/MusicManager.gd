extends AudioStreamPlayer

const MENU_MUSIC = preload("res://Assets/Tracks/Cuddle Clouds.wav")
const PAUSE_MUSIC = preload("res://Assets/Tracks/Evening Harmony.wav")

const GAME_MUSIC_PLAYLIST = [
	preload("res://Assets/Tracks/Drifting Memories.wav"),
	preload("res://Assets/Tracks/Forgotten Biomes.wav"),
	preload("res://Assets/Tracks/Polar Lights.wav"),
	preload("res://Assets/Tracks/Strange Worlds.wav")
]

var current_track_index = 0
var game_music_position = 0.0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	finished.connect(_on_finished)
	
	# switching to the next one
	for track in GAME_MUSIC_PLAYLIST:
		if track is AudioStreamWAV:
			track.loop_mode = AudioStreamWAV.LOOP_DISABLED

func play_main_menu_music():
	if stream != MENU_MUSIC:
		stream = MENU_MUSIC
		volume_db = -10.0
		play()

func play_game_music():
	# If we are already playing a track from the playlist, don't interrupt
	if stream in GAME_MUSIC_PLAYLIST and playing:
		return
		
	# Check if we were playing pause music, if so resume
	var start_pos = 0.0
	if stream == PAUSE_MUSIC:
		start_pos = game_music_position
		
	# Otherwise, start playing the current track (or random/first)
	_play_game_track(current_track_index, start_pos)

func play_pause_music():
	if stream in GAME_MUSIC_PLAYLIST:
		game_music_position = get_playback_position()
		
	if stream != PAUSE_MUSIC:
		stream = PAUSE_MUSIC
		volume_db = -10.0
		play()

func _play_game_track(index, start_pos = 0.0):
	if GAME_MUSIC_PLAYLIST.is_empty():
		return
		
	current_track_index = index % GAME_MUSIC_PLAYLIST.size()
	stream = GAME_MUSIC_PLAYLIST[current_track_index]
	volume_db = -10.0 # Adjusted volume for game music
	play(start_pos)

func _on_finished():
	if stream == MENU_MUSIC or stream == PAUSE_MUSIC:
		play() # Loop these tracks
	elif stream in GAME_MUSIC_PLAYLIST:
		# Play next track in playlist (from start)
		_play_game_track(current_track_index + 1)

func reset_game_music():
	current_track_index = 0
	game_music_position = 0.0
	# Should we stop playback? Usually 'play_game_music' will be called soon after manually.
	# But if we want to ensure it starts fresh:
	stop()
	stream = null 
