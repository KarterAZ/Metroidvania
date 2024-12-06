extends Node2D

const Global = preload("res://scripts/global.gd")

@export var restore_red_ink: bool = false
@export var direction: int = Global.down

func _on_restore_area_body_entered(body: Node2D) -> void:
	if body.has_method("inkwell"):
		print(restore_red_ink, direction)
		body.inkwell(restore_red_ink, direction)
