extends Node2D

const Global = preload("res://scripts/global.gd")
const DUAL_WELLS = preload("res://items/dual_wells.png")
const INKWELL = preload("res://items/inkwell.png")

@onready var sprite: Sprite2D = %Sprite

@export var sound_byte: AudioStreamMP3 = null
@export var restore_red_ink: bool = false
@export var direction: int = Global.down

var first: bool = true

func _ready() -> void:
	if restore_red_ink == true:
		sprite.texture = DUAL_WELLS
	else:
		sprite.texture = INKWELL

func _on_restore_area_body_entered(body: Node2D) -> void:
	if body.has_method("inkwell"):
		body.inkwell(restore_red_ink, direction, first, sound_byte)
		first = false
