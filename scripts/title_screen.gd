extends Node2D

@onready var start = %Start_Game
@onready var end = %Quit_Game

var starting_room = "res://scenes/Starting_Room.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start.grab_focus()
	get_tree().paused = false

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file(starting_room)
	
func _on_quit_game_pressed() -> void:
	get_tree().quit()

func _on_start_game_mouse_entered() -> void:
	start.grab_focus()

func _on_start_game_mouse_exited() -> void:
	start.release_focus()

func _on_quit_game_mouse_entered() -> void:
	end.grab_focus()

func _on_quit_game_mouse_exited() -> void:
	end.release_focus()

func _input(input:InputEvent) -> void:
	if input.as_text() == "Up" or input.as_text() == "Down" or input.as_text() == "Enter":
		if not start.has_focus() and not end.has_focus():
			start.grab_focus()
