extends Node2D

func _on_restore_area_body_entered(body: Node2D) -> void:
	if body.has_method("give_ink"):
		body.give_ink()
	if body.has_method("give_health"):
		body.give_health()
