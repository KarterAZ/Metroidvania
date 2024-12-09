extends Node2D

const CHARGE_STAB = preload("res://scenes/Charge_Stab.tscn")

@onready var character: CharacterBody2D = %Character
@onready var game_over: Control = %GameOver
@onready var platforms: TileMapLayer = %Platforms
@onready var water: AnimationPlayer = %water
@onready var water_effect: Sprite2D = $water/water_effect

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

func _on_character_water_blotch(wet_bodies: Array[Node2D]) -> void:
	print("emitted", wet_bodies)
	for wet_body in wet_bodies:
		if not wet_body.has_method("attack_receive"):
			var x: int = floor(character.position.x/platforms.tile_set.tile_size.x)
			var y: int = floor(character.position.y/platforms.tile_set.tile_size.y)-2
			var coords: Array[Vector2i] = []
			for i in range(3):
				for j in range(3):
					coords.append(Vector2i(x+i-1, y+j-1)) #Gets square around player
					
			for coord in coords:
				var tile = platforms.get_cell_tile_data(coord)
				print(tile)
				if (tile != null) and (tile.probability == 2):
					#if collision on physics layer 2
					platforms.erase_cell(coord)
				

func _on_character_water_blotch_start() -> void:
	water_effect.position = character.position
	water_effect.visible = true
	water.play("new_animation")

func _on_water_animation_finished(anim_name: StringName) -> void:
	if anim_name == "new_animation":
		water_effect.visible = false
