extends Node2D

const CHARGE_STAB = preload("res://scenes/Charge_Stab.tscn")
@onready var character: CharacterBody2D = %Character

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _on_character_charge_stab() -> void:
	var ink = CHARGE_STAB.instantiate()
	ink.position.x = character.position.x
	ink.position.y = character.position.y
	ink.rotation = character.rotation
	add_child(ink)
