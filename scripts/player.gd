extends CharacterBody2D

@export var min_speed = 100
@export var max_speed = 300

@export var min_gravity = 50
@export var max_gravity = 150

@export var num_jumps = 2
@export var jump_force = 1500

var speed = min_speed
var gravity = max_speed

@onready var sprite = %Player_Sprite

var cur_jumps = 0
var last_direction = 0

func _physics_process(delta):
	if !is_on_floor():
		if Input.is_action_just_pressed("Jump") and num_jumps > cur_jumps:
			cur_jumps += 1
			velocity.y = -jump_force
			gravity = min_gravity
		else:
			velocity.y = velocity.y + gravity if gravity < max_gravity else max_gravity
			gravity += 5
		
	else:
		cur_jumps = 0
		gravity = min_gravity
		if Input.is_action_just_pressed("Jump"):
			cur_jumps += 1
			velocity.y = -jump_force
	
	var horizontal_direction = Input.get_axis("Left", "Right")
	if horizontal_direction != last_direction:
		speed += 25
		sprite.flip_h = (horizontal_direction == 1)
	else:
		speed = min_speed
		last_direction = horizontal_direction
	velocity.x = horizontal_direction * speed if speed < max_speed else horizontal_direction * max_speed
	
	move_and_slide()
