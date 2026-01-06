extends Area2D

@export var id: String = ""

func _ready() -> void:
	if id == "":
		id = str(global_position)
		
	if Globals.is_key_collected(id):
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("add_keys"):
		Globals.register_key_collected(id)
		body.add_keys()
		queue_free()
	else:
		pass
