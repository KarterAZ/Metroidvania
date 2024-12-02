extends Control

var main_menu = "res://scenes/Title_Screen.tscn"

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file(main_menu)
