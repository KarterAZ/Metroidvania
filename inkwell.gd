extends Node2D

func _on_restore_area_body_entered(body: Node2D) -> void:
	if body.has_method("inkwell"):
		body.inkwell()
