class_name HealthBar
extends Node2D

@export var max_value: int = 3
@export var value: int = 3
@export var bar_width: int = 20
@export var bar_height: int = 3
@export var background_color: Color = Color(0, 0, 0, 0.7)
@export var good_color: Color = Color(0.2, 0.8, 0.2, 1.0)
@export var mid_color: Color = Color(0.9, 0.8, 0.2, 1.0)
@export var low_color: Color = Color(0.9, 0.2, 0.2, 1.0)

var margin: int = 1

func _ready() -> void:
	set_as_top_level(false)
	z_index = 100
	queue_redraw()

func set_max_value(new_max: int) -> void:
	max_value = max(new_max, 1)
	value = min(value, max_value)
	queue_redraw()

func set_value(new_value: int) -> void:
	value = clamp(new_value, 0, max_value)
	queue_redraw()

func _draw() -> void:
	# Background
	draw_rect(Rect2(Vector2(-bar_width / 2, -bar_height / 2), Vector2(bar_width, bar_height)), background_color, true)
	
	if max_value <= 0:
		return
	var pct := float(value) / float(max_value)
	var fill_width := int((bar_width - margin * 2) * pct)
	var fill_color := _get_fill_color(pct)
	# Fill
	draw_rect(Rect2(Vector2(-bar_width / 2 + margin, -bar_height / 2 + margin), Vector2(fill_width, bar_height - margin * 2)), fill_color, true)

func _get_fill_color(pct: float) -> Color:
	if pct > 0.6:
		return good_color
	elif pct > 0.3:
		return mid_color
	return low_color
