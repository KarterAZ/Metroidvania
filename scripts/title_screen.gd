extends Node2D

@onready var start = $MarginContainer/Menu_Options/Start_Game
var starting_room = "res://scenes/Starting_Room.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start.grab_focus()

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file(starting_room)
	
func _on_quit_game_pressed() -> void:
	get_tree().quit()
