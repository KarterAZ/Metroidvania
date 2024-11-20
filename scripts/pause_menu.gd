extends Control

@onready var menu = $"."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	open_close_menu()
	
func pause() -> void:
	get_tree().paused = true
	menu.visible = true
		
func resume() -> void:
	get_tree().paused = false
	menu.visible = false

func open_close_menu() -> void:
	if Input.is_action_just_pressed("Menu") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("Menu") and get_tree().paused:
		resume()

func _on_resume_game_pressed() -> void:
	resume()

func _on_exit_game_pressed() -> void:
	get_tree().quit()
