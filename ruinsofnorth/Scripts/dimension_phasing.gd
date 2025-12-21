extends Node2D

enum DimensionType {
	NORMAL = 0,
	FLIPPED = 1,
	BOTH = 2
}

@export var target_dimension : DimensionType = DimensionType.NORMAL
@export var fade_duration : float = 0.3

# Cache references and initial state
var parent_collision_object = null
var parent_tile_layer = null

func _ready():
	# Use duck typing to avoid parser errors with script types
	if "collision_layer" in self:
		parent_collision_object = self
	if "tile_set" in self: # TileMapLayer has tile_set property
		parent_tile_layer = self
		
	# Connect to the global signal
	Globals.flip_toggled.connect(_on_flip_toggled)
	
	# Set initial state
	_update_state(Globals.flipped, true)

func _on_flip_toggled(is_flipped):
	_update_state(is_flipped, false)

func _update_state(is_flipped: bool, immediate: bool):
	var should_exist = false
	
	match target_dimension:
		DimensionType.BOTH:
			should_exist = true
		DimensionType.NORMAL:
			should_exist = not is_flipped
		DimensionType.FLIPPED:
			should_exist = is_flipped
	
	# 1. Handle Visuals (Opacity)
	var target_modulate = Color(modulate.r, modulate.g, modulate.b, 1.0 if should_exist else 0.0)
	
	if immediate:
		modulate = target_modulate
		if not should_exist:
			hide() # Fully hide to be safe
		else:
			show()
	else:
		show() # Ensure visible for fade
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", target_modulate, fade_duration)
		
		# If fading out, hide after finished to save draw calls
		if not should_exist:
			tween.tween_callback(self.hide)

	# 2. Handle Logic/Physics (Process Mode)
	# We perform this immediately so physics don't linger during the fade
	if should_exist:
		process_mode = Node.PROCESS_MODE_INHERIT
	else:
		process_mode = Node.PROCESS_MODE_DISABLED

	# 3. Handle Specific Physics Nodes
	# TileMapLayers and CollisionObjects might need extra help if process_mode isn't enough
	if parent_tile_layer:
		parent_tile_layer.enabled = should_exist
		parent_tile_layer.collision_enabled = should_exist
