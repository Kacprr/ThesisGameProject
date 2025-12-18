extends Area2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

var active = false

func _ready():
	# If this checkpoint is currently active (player spawned here), remove it immediately.
	if Globals.checkpoint_active and global_position == Globals.current_checkpoint_position:
		queue_free()
		return

	# Connect the signal via code to ensure it works even if not linked in editor
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("Player") and not active:
		activate_checkpoint(body)

func activate_checkpoint(_player):
	active = true
	Globals.update_checkpoint(global_position)
	
	if animated_sprite:
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(animated_sprite, "modulate:a", 0.0, 0.5)
		tween.tween_property(animated_sprite, "scale", Vector2(0, 0), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.chain().tween_callback(queue_free)
		
