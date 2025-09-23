extends CanvasLayer

@onready var health_bar: ProgressBar = $UIFrame/HealthBar
@onready var score_label: Label = $UIFrame/ScoreContainer/ScoreLabel

var max_health: int = 5
var _health_tween: Tween
var _pending_score: int = -1
var _pending_health: int = -1
var _pending_max_health: int = -1
var _is_quitting: bool = false

func _ready() -> void:
	# Initialize queued values safely
	if _pending_max_health >= 0:
		set_max_health(_pending_max_health)
		_pending_max_health = -1
	else:
		health_bar.max_value = max_health
	
	if _pending_health >= 0:
		_update_health_internal(_pending_health)
		_pending_health = -1
	else:
		health_bar.value = max_health
	
	if _pending_score >= 0:
		score_label.text = str(_pending_score)
		_pending_score = -1

func _exit_tree() -> void:
	_is_quitting = true
	if _health_tween and _health_tween.is_running():
		_health_tween.kill()

func set_max_health(value: int) -> void:
	if _is_quitting:
		return
	if not is_inside_tree() or health_bar == null:
		_pending_max_health = value
		return
	max_health = max(value, 1)
	health_bar.max_value = max_health
	health_bar.value = clampi(health_bar.value, 0, max_health)

func update_health(value: int) -> void:
	if _is_quitting:
		return
	if not is_inside_tree() or health_bar == null:
		_pending_health = value
		return
	_update_health_internal(value)

func _update_health_internal(value: int) -> void:
	if _is_quitting:
		return
	var target: int = clampi(value, 0, max_health)
	if _health_tween and _health_tween.is_running():
		_health_tween.kill()
	_health_tween = create_tween()
	_health_tween.tween_property(health_bar, "value", target, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func update_score(score: int) -> void:
	if _is_quitting:
		return
	if not is_inside_tree() or score_label == null:
		_pending_score = score
		return
	score_label.text = str(score)

func _on_player_health_changed(health: Variant) -> void:
	update_health(int(health))
