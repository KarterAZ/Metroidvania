extends Node2D

@onready var hitbox: CollisionShape2D = %Hitbox

signal ink_screen

func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body.has_method("ink_get"):
		body.ink_get()
		hitbox.set_deferred("disabled", true)
		self.visible = false
		ink_screen.emit()
