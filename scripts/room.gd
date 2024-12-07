extends Node2D

const CHARGE_STAB = preload("res://scenes/Charge_Stab.tscn")

@onready var character: CharacterBody2D = %Character
@onready var game_over: Control = %GameOver

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _on_character_charge_stab() -> void:
	var ink = CHARGE_STAB.instantiate()
	ink.position.x = character.position.x
	ink.position.y = character.position.y
	ink.rotation = character.rotation
	add_child(ink)

func _on_character_dead() -> void:
	game_over.visible = true
	get_tree().paused = true

func _on_change_grav_left_body_entered(body: Node2D) -> void:
	if body.has_method("change_grav"):
		body.change_grav(true)
