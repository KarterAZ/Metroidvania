extends Control

var main_menu = "res://scenes/Title_Screen.tscn"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	open_close_menu()
	
func pause() -> void:
	self.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	get_tree().paused = true
	self.visible = true
		
func resume() -> void:
	get_tree().paused = false
	self.set_process_mode(Node.PROCESS_MODE_INHERIT)
	self.visible = false

func open_close_menu() -> void:
	if Input.is_action_just_pressed("Menu") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("Menu") and get_tree().paused:
		resume()

func _on_resume_game_pressed() -> void:
	resume()

func _on_exit_game_pressed() -> void:
	get_tree().quit()

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file(main_menu)
