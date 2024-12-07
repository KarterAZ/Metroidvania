extends Node2D

@onready var hitbox: CollisionShape2D = %Hitbox

func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body.has_method("health_up_get"):
		body.health_up_get()
		hitbox.set_deferred("disabled", true)
		self.visible = false
