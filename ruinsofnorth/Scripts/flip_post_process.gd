extends CanvasLayer

@onready var color_rect = $ColorRect

func _ready():
	Globals.flip_toggled.connect(_on_flip_toggled)
	# Check initial state without animation
	var initial_val = 1.0 if Globals.flipped else 0.0
	if color_rect.material:
		color_rect.material.set_shader_parameter("mix_amount", initial_val)

func _on_flip_toggled(is_flipped):
	var target_val = 1.0 if is_flipped else 0.0
	if color_rect.material:
		var tween = get_tree().create_tween()
		tween.tween_property(color_rect.material, "shader_parameter/mix_amount", target_val, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
