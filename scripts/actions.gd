extends Node

@onready var menu = load("res://scenes/Menu.tscn").instance()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.action_press("Menu")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(input:InputEvent) -> void:
	if Input.is_action_just_pressed("Menu"):
		print("Menu opened")
		
		#Toggle paused game and open menu
		get_tree().current_scene.add_child(menu)
