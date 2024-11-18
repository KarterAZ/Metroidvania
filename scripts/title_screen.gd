extends Node2D

@onready var start = $MarginContainer/Menu_Options/Start_Game
@onready var end = $MarginContainer/Menu_Options/Quit_Game
var starting_room = "res://scenes/Starting_Room.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start.connect("button_up", start_game)
	end.connect("button_up", end_game)

func start_game() -> void:
	get_tree().change_scene_to_file(starting_room)

func end_game() -> void:
	get_tree().quit()
