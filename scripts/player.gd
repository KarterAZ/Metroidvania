extends CharacterBody2D

const Global = preload("res://scripts/global.gd")

@export var min_speed:int = 100
@export var max_speed:int = 500
@export var speed_per_second:int = 800

@export var min_gravity:int = 100
@export var max_gravity:int = 900
@export var gravity_per_second:int = 200

@export var num_jumps:int = 2
@export var jump_force:int = 1500

var speed:int = min_speed
var gravity:int = max_speed
var cur_jumps:int = 0
var grav_direction:int = Global.down
var on_ground:bool = true

@onready var sprite: Node2D = %Node2D
@onready var anims: AnimationPlayer = %AnimationPlayer
@onready var cam: Camera2D = %Player_Cam
@onready var floor: Area2D = $On_Floor

func set_grav_velocity(x, y) -> void:
	if grav_direction == Global.down:
		velocity.x = x
		velocity.y = y
	if grav_direction == Global.right:
		velocity.x = y
		velocity.y = -x
	if grav_direction == Global.up:
		velocity.x = -x
		velocity.y = -y
	if grav_direction == Global.left:
		velocity.x = -y
		velocity.y = x
		
func get_grav_velocity_x() -> float:
	if grav_direction == Global.down:
		return velocity.x
	if grav_direction == Global.right:
		return velocity.y * -1
	if grav_direction == Global.up:
		return velocity.x * -1
	if grav_direction == Global.left:
		return velocity.y
	else:
		return 0
		
func get_grav_velocity_y() -> float:
	if grav_direction == Global.down:
		return velocity.y
	if grav_direction == Global.right:
		return velocity.x
	if grav_direction == Global.up:
		return velocity.y * -1
	if grav_direction == Global.left:
		return velocity.x * -1
	else:
		return 0

func _physics_process(delta):
	var horizontal_direction = Input.get_axis("Left", "Right")
	var velocityx = get_grav_velocity_x()
	var velocityy = get_grav_velocity_y()
	
	if on_ground:
		cur_jumps = 0
		gravity = min_gravity
		if Input.is_action_just_pressed("Grav_Left"):
			grav_direction = Global.left_dir(grav_direction)
			cam.rotate(PI * .5)
			sprite.rotate(PI * .5)
		elif Input.is_action_just_pressed("Grav_Right"):
			grav_direction = Global.right_dir(grav_direction)
			cam.rotate(PI * -.5)
			sprite.rotate(PI * -.5)
		elif Input.is_action_just_pressed("Jump"):
			cur_jumps += 1
			velocityy = -jump_force
	else:
		if Input.is_action_just_pressed("Jump") and num_jumps > cur_jumps:
			cur_jumps += 1
			velocityy = -jump_force
			gravity = min_gravity
		else:
			gravity += gravity_per_second * delta
			velocityy = velocityy + gravity if gravity < max_gravity else max_gravity
	
	#Set speed
	speed += speed_per_second * delta
	
	#Set animations
	if horizontal_direction == 0:
		anims.play("Idle")
	elif horizontal_direction != 0:
		anims.play("Run")
			
	#If changed directions
	if (horizontal_direction < 0 and sprite.scale.x > 0) or (horizontal_direction >= 0 and sprite.scale.x < 0):
		speed = min_speed
		sprite.scale.x *= -1
	
	velocityx = horizontal_direction * speed if speed < max_speed else horizontal_direction * max_speed
	
	set_grav_velocity(velocityx, velocityy)
	
	move_and_slide()

func _on_on_floor_body_entered(body: Node2D) -> void:
	on_ground = true

func _on_on_floor_body_exited(body: Node2D) -> void:
	on_ground = false
