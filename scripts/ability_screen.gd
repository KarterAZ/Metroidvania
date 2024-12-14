extends Control


func pause() -> void:
	self.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	get_tree().paused = true
	self.visible = true
		
func resume() -> void:
	get_tree().paused = false
	self.set_process_mode(Node.PROCESS_MODE_INHERIT)
	self.visible = false

func _on_resume_game_pressed() -> void:
	resume()
