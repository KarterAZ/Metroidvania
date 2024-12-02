extends Node2D

@export var restore_red_ink: bool = false

func _on_restore_area_body_entered(body: Node2D) -> void:
	if body.has_method("inkwell"):
		body.inkwell(restore_red_ink)
