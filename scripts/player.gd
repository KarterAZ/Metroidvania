extends CharacterBody2D

const Global = preload("res://scripts/global.gd")

@export var min_speed: int = 200
@export var max_speed: int = 600
@export var speed_per_second: int = 800

@export var min_gravity: int = 75
@export var max_gravity: int = 875
@export var gravity_per_second: int = 100

@export var num_jumps: int = 2
@export var jump_force: int = 1500

@export var grav_frames: int = 5

@export var charge_stab_cost: int = 10
@export var grav_cost: int = 0
@export var water_cost: int = 5

@export var ink_restore_amount: int = 15
@export var health_restore_amount: int = 15

var speed: int = min_speed
var gravity: int = max_speed
var cur_jumps: int = 0
var grav_direction: int = Global.down
var on_ground: bool = false
var go_left: int = 0
var go_right: int = 0
var grav_increment: float = (PI * .5) / grav_frames
var can_act: bool = true
var restore_ink: bool = false
var restore_health: bool = false
var pain_position: Vector2 = Vector2(0, 0)
var pain_direction: int = Global.down
var heal_on_reset: bool = false
var ink_on_reset: bool = false

@onready var sprites: Node2D = %Animation_Handler
@onready var sam: AnimationPlayer = %Sam
@onready var idle: Sprite2D = %Idle
@onready var run: Sprite2D = %Run
@onready var sword: Sprite2D = %Sword

@onready var cam: Camera2D = %Player_Cam
@onready var health: ProgressBar = %Health
@onready var ink: ProgressBar = %Ink

signal dead
signal charge_stab
signal water
#signal gravity_left
#signal gravity_right

func _ready():
	speed = min_speed
	gravity = max_speed
	cur_jumps = 0
	grav_direction = Global.down
	on_ground = false
	go_left = 0
	go_right = 0
	grav_increment = (PI * .5) / grav_frames
	can_act = true
	restore_ink = false
	restore_health = false
	pain_position = self.get_global_position()
	
func new_reset_position(heal, ink, direction) -> void:
	print(heal, ink, direction)
	pain_position = self.get_global_position()
	pain_direction = direction
	heal_on_reset = heal
	ink_on_reset = ink
	
func reset_position() -> void:
	self.set_global_position(pain_position)
	grav_direction = pain_direction
	self.rotation_degrees = pain_direction * -90

func give_ink() -> void:
	restore_ink = true
	
func give_health() -> void:
	restore_health = true
	
func inkwell(restore_red_ink, direction) -> void:
	give_ink()
	if restore_red_ink:
		give_health()
		new_reset_position(true, true, direction)
	else:
		new_reset_position(false, true, direction)

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
		
func hide_sprites() -> void:
	idle.visible = false
	run.visible = false
	sword.visible = false
	
func change_grav(change_left : bool) -> void:
	if change_left:
		grav_direction = Global.left_dir(grav_direction)
		go_left = grav_frames - 1
		self.set_process_mode(Node.PROCESS_MODE_ALWAYS)
		get_tree().paused = true
		can_act = false
		self.rotate(grav_increment)
	else:
		grav_direction = Global.right_dir(grav_direction)
		go_right = grav_frames - 1
		self.set_process_mode(Node.PROCESS_MODE_ALWAYS)
		get_tree().paused = true
		can_act = false
		self.rotate(grav_increment * -1)
	
func _physics_process(delta):
	#Gravity stuff
	if go_left > 0:
		self.rotate(grav_increment)
		go_left -= 1
		if go_left == 0:
			get_tree().paused = false
			self.set_process_mode(Node.PROCESS_MODE_INHERIT)
			can_act = true
			
	elif go_right > 0:
		self.rotate(grav_increment * -1)
		go_right -= 1
		if go_right == 0:
			get_tree().paused = false
			self.set_process_mode(Node.PROCESS_MODE_INHERIT)
			can_act = true
	
	if on_ground:
		if Input.is_action_just_pressed("Grav_Left") and can_act:
			change_grav(true)
			
		elif Input.is_action_just_pressed("Grav_Right") and can_act:
			change_grav(false)
			
	#Ink stuff
	if Input.is_action_just_pressed("Ink"):
		if ink.value >= charge_stab_cost:
			ink.value -= charge_stab_cost
			charge_stab.emit()
			
	#Water stuff
	if Input.is_action_just_pressed("Water"):
		if ink.value >= water_cost:
			ink.value -= water_cost
			water.emit()
			
	#Attack stuff
	if Input.is_action_just_pressed("Attack"):
		hide_sprites()
		sword.visible = true
		sam.play("Sword")
		can_act = false
			
	#Inkwell restore stuff
	if restore_ink:
		ink.value += ink_restore_amount
		if ink.value >= ink.max_value:
			restore_ink = false
			
	if restore_health:
		health.value += health_restore_amount
		if health.value >= health.max_value:
			restore_health = false
			
	#Physics stuff
	var horizontal_direction = 0
	if can_act:
		horizontal_direction = Input.get_axis("Left", "Right")
	
	var velocityx = get_grav_velocity_x()
	var velocityy = get_grav_velocity_y()
		
	if on_ground:
		cur_jumps = 0
		gravity = min_gravity
		if Input.is_action_just_pressed("Jump") and can_act:
			cur_jumps += 1
			velocityy = -jump_force
	else:
		if Input.is_action_just_pressed("Jump") and num_jumps > cur_jumps and can_act:
			cur_jumps += 2
			velocityy = -jump_force
			gravity = min_gravity
		else:
			gravity += gravity_per_second * delta
			velocityy = velocityy + gravity if gravity < max_gravity else max_gravity
		
	#Set speed
	speed += speed_per_second * delta
		
	#Set animations
	if horizontal_direction == 0 and can_act:
		hide_sprites()
		idle.visible = true
		sam.play("Idle")
	elif horizontal_direction != 0:
		hide_sprites()
		run.visible = true
		sam.play("Run")
				
	#If changed directions
	if can_act and ((horizontal_direction < 0 and sprites.scale.x > 0) or (horizontal_direction > 0 and sprites.scale.x < 0)):
		speed = min_speed
		sprites.scale.x *= -1
		
	velocityx = horizontal_direction * speed if speed < max_speed else horizontal_direction * max_speed
		
	set_grav_velocity(velocityx, velocityy)
		
	move_and_slide()

func _on_on_floor_body_entered(body: Node2D) -> void:
	if body != self:
		on_ground = true

func _on_on_floor_body_exited(_body: Node2D) -> void:
	on_ground = false

func _on_sam_animation_finished(_anim_name: StringName) -> void:
	can_act = true

func _on_hitbox_body_entered(_body: Node2D) -> void:
	health.value -= 5
	if health.value == 0:
		dead.emit()
	reset_position()
