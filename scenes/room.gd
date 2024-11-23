extends Node2D

const CHARGE_STAB = preload("res://scenes/Charge_Stab.tscn")
@onready var character: CharacterBody2D = %Character

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Ink"):
		var ink = CHARGE_STAB.instantiate()
		ink.position.x += character.position.x
		ink.position.y += character.position.y
		add_child(ink)
