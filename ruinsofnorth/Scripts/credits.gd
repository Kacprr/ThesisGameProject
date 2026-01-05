extends Control

@export var scroll_speed: float = 60.0 # Pixels per second
@export var fade_time: float = 1.0
@export var end_delay: float = 3.0

@onready var container = $VBoxContainer
@onready var title = $VBoxContainer/Title
@onready var content = $VBoxContainer/Content

var _tween: Tween
var _scrolling: bool = false

func _ready() -> void:
	# Start transparent
	modulate.a = 0.0
	
	# Setup initial position: Start below the screen
	call_deferred("_start_sequence")

func _start_sequence() -> void:
	# Wait for UI layout to calculate sizes
	await get_tree().process_frame
	await get_tree().process_frame

	var screen_height = get_viewport_rect().size.y
	# Start just below screen
	container.position.y = screen_height
	
	print("Screen Height: ", screen_height)
	print("Container Size: ", container.size)
	print("Container Pos: ", container.position)
	
	# Fade In (Background + Text)
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 1.0, fade_time)

	fade_tween.tween_callback(_start_scrolling)

func _start_scrolling() -> void:
	_scrolling = true
	var container_height = container.size.y
	
	var target_y = -container_height
	var distance = abs(target_y - container.position.y)
	var duration = distance / scroll_speed
	
	_tween = create_tween()
	_tween.tween_property(container, "position:y", target_y, duration).set_trans(Tween.TRANS_LINEAR)
	_tween.tween_interval(end_delay)
	_tween.tween_callback(_fade_out_and_exit)

func _fade_out_and_exit() -> void:
	if _tween:
		_tween.kill()
	
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, fade_time)
	fade_tween.tween_callback(go_to_menu)

func _process(delta: float) -> void:
	# Optional: Manual input handling to speed up or skip
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		_fade_out_and_exit()
	elif event is InputEventMouseButton and event.pressed:
		_fade_out_and_exit()

func go_to_menu() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
