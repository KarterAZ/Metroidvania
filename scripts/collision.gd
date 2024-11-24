extends CollisionShape2D

func activate_area() -> void:
	self.disabled = false
	
func deactivate_area() -> void:
	self.disabled = true
