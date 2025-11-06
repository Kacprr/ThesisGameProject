extends CanvasLayer

@onready var health_bar: ProgressBar = $UIFrame/HealthBar
@onready var score_label: Label = $UIFrame/ScoreContainer/ScoreLabel
@onready var stamina_bar: ProgressBar = $UIFrame/StaminaBar
@onready var hp_number_label: Label = %HpNumberLabel
@onready var stamina_number_label: Label = %StaminaNumberLabel

var max_health: int = 100
var max_stamina: int = 100
var _health_tween: Tween
var _stamina_tween: Tween
var _pending_score: int = -1
var _pending_health: int = -1
var _pending_max_health: int = -1
var _is_quitting: bool = false

func _ready() -> void:
	stamina_bar.max_value = float(max_stamina)
	stamina_bar.value = float(max_stamina)
	
	hp_number_label.text = str(max_health)
	stamina_number_label.text = str(max_stamina)
	
	var player = get_node_or_null("../Player")
	if player:
		if player.is_connected("stamina_changed", Callable(self, "_on_player_stamina_changed")) == false:
			player.connect("stamina_changed", Callable(self, "_on_player_stamina_changed"))
	
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
	
	if is_inside_tree() and hp_number_label:
		hp_number_label.text = str(clampi(health_bar.value, 0, max_health))

func update_health(value: int) -> void:
	if _is_quitting:
		return
	if not is_inside_tree() or health_bar == null:
		_pending_health = value
		return
	_update_health_internal(value)
	hp_number_label.text = str(clampi(value, 0, max_health))

func _update_health_internal(value: int) -> void:
	if _is_quitting:
		return
	var target: int = clampi(value, 0, max_health)
	if _health_tween and _health_tween.is_running():
		_health_tween.kill()
	_health_tween = create_tween()
	_health_tween.tween_property(health_bar, "value", target, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func update_stamina(value: float) -> void:
	if _is_quitting:
		return
	if not is_inside_tree() or stamina_bar == null:
		return
		
	var target: float = clampi(value, 0 , max_stamina)
	
	if _stamina_tween and _stamina_tween.is_running():
		_stamina_tween.kill()
		
	_stamina_tween = create_tween()
	_stamina_tween.tween_property(stamina_bar, "value", target, 0.1).set_trans(Tween.TRANS_SINE)
	
	stamina_number_label.text = str(ceil(target))

func _on_player_stamina_changed(stamina: float) -> void:
	update_stamina(stamina)

func update_score(score: int) -> void:
	if _is_quitting:
		return
	if not is_inside_tree() or score_label == null:
		_pending_score = score
		return
	score_label.text = str(score)

func _on_player_health_changed(health: Variant) -> void:
	update_health(int(health))
