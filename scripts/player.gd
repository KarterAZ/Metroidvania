extends CharacterBody2D

const Global = preload("res://scripts/global.gd")

@export var is_player: bool = true
@export var is_final_boss: bool = false

@export var min_speed: int = 400
@export var max_speed: int = 800
@export var speed_per_second: int = 800

@export var min_gravity: int = 75
@export var max_gravity: int = 875
@export var gravity_per_second: int = 100

@export var num_jumps: int = 2
@export var jump_force: int = 1500
@export var knockback: int = 800

@export var grav_frames: int = 5

@export var charge_stab_cost: int = 10
@export var grav_cost: int = 0
@export var water_cost: int = 20
@export var sword_cost: int = 5

@export var sword_damage: int = 10
@export var water_damage: int = 25

@export var ink_restore_amount: int = 15
@export var health_restore_amount: int = 15

@export var max_health: int = 100
@export var max_ink: int = 30

@export var can_ink: bool = false
@export var can_water: bool = false
@export var can_grav: bool = false

var speed: int = min_speed
var gravity: int = max_speed
var cur_jumps: int = 0
var last_direction: int = 0
var grav_direction: int = Global.down
var on_ground: bool = false
var go_left: int = 0
var go_right: int = 0
var grav_increment: float = (PI * .5) / grav_frames
var can_act: bool = true
var can_attack: bool = true
var restore_ink: bool = false
var restore_health: bool = false
var pain_position: Vector2 = Vector2(0, 0)
var pain_direction: int = Global.down
var heal_on_reset: bool = false
var ink_on_reset: bool = false
var attacking: int = Global.no_attack
var hit_bodies: Array[Node2D] = []
var has_sword: int = Global.red_sword
var wet_bodies: Array[Node2D] = []
var suffer_in_ice_physics: bool = false

@onready var sprites: Node2D = %Animation_Handler
@onready var sam: AnimationPlayer = %Sam
@onready var idle: Sprite2D = %Idle
@onready var run: Sprite2D = %Run
@onready var sword: Sprite2D = %Sword
@onready var water: Sprite2D = %Water
@onready var hit: Area2D = %Hit
@onready var repair_timer: Timer = %Repair_Timer

@onready var cam: Camera2D = %Player_Cam
@onready var health: ProgressBar = %Health
@onready var ink: ProgressBar = %Ink

#Enemy stuff
var enemy_left: bool = false
var enemy_right: bool = false
var attack_enemy: bool = false
var attack_delay: int = 0

@export var min_enemy_attack_delay: float = 40
@export var max_enemy_attack_delay: float = 90

@onready var left_detection: CollisionShape2D = %Left_Detection
@onready var right_detection: CollisionShape2D = %Right_Detection
@onready var enemy_detection_attack: CollisionShape2D = %Enemy_Detection_Attack
@onready var win_timer: Timer = %Win_Timer

signal dead
signal charge_stab
signal water_blotch
signal water_blotch_start
signal gravity_left
signal gravity_right

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
	health.max_value = max_health
	ink.max_value = max_ink
	
	if is_player:
		left_detection.set_deferred("disabled", true)
		right_detection.set_deferred("disabled", true)
		enemy_detection_attack.set_deferred("disabled", true)
	else:
		cam.visible = false
	
func new_reset_position(heal, fill_ink, direction) -> void:
	pain_position = self.get_global_position()
	pain_direction = direction
	heal_on_reset = heal
	ink_on_reset = fill_ink
	
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

func ink_get() -> void:
	can_ink = true
	#TODO: play audio, maybe text for controls?
	
func water_get() -> void:
	can_water = true
	#TODO: play audio, maybe text for controls?
	
func grav_get() -> void:
	can_grav = true
	#TODO: play audio, maybe text for controls?
	
func health_up_get() -> void:
	health.max_value += 10
	health.value = health.max_value
	
func ink_up_get() -> void:
	ink.max_value += 10
	ink.value = ink.max_value
	
func bad_collision_start() -> void:
	attacking = Global.bad_attack
	
func parry_collision_start() -> void:
	attacking = Global.good_attack
	
func no_collision_start() -> void:
	attacking = Global.no_attack
	
func water_attack_give() -> void:
	water_blotch.emit(wet_bodies)
	print(wet_bodies)
	for wet_body in wet_bodies:
		if wet_body.has_method("attack_receive"):
			wet_body.attack_receive(water_damage)
	
func attack_give() -> void:
	for hit_body in hit_bodies:
		if hit_body.has_method("attack_receive"):
			hit_body.attack_receive(sword_damage)
			
func attack_receive(damage_value: int) -> void:
	if attacking == Global.good_attack:
		ink.value += 5
		pass #TODO: Have feedback for player on parry
	else:
		if attacking == Global.bad_attack:
			if has_sword != Global.no_sword:
				has_sword -= 1
		health.value -= damage_value
		if sam.is_playing():
			sam.stop()
			can_attack = true
	
		#Knockback
		suffer_in_ice_physics = true
		set_grav_velocity((get_grav_velocity_x() + knockback) * -1 * last_direction, get_grav_velocity_y() - (knockback / 2))
		move_and_slide()
		
		if(is_player):
			reset_position()

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
	water.visible = false
	
func change_grav(change_left : bool) -> void:
	ink.value -= grav_cost
	
	if change_left:
		gravity_left.emit()
		grav_direction = Global.left_dir(grav_direction)
		go_left = grav_frames - 1
		self.rotate(grav_increment)
	else:
		gravity_right.emit()
		grav_direction = Global.right_dir(grav_direction)
		go_right = grav_frames - 1
		self.rotate(grav_increment * -1)
		
	self.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	get_tree().paused = true
	can_act = false
	
func _physics_process(delta):
	#Check if dead
	if health.value == 0:
		if is_player:
			dead.emit()
		elif is_final_boss:
			win_timer.start()
			self.visible = false
			enemy_left = false
			enemy_right = false
			attack_enemy = false
			attack_delay = 1000000
			left_detection.set_deferred("disabled", true)
			right_detection.set_deferred("disabled", true)
			enemy_detection_attack.set_deferred("disabled", true)
			can_act = false
		else:
			self.queue_free()
		
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
		if Input.is_action_just_pressed("Grav_Left") and can_act and can_grav and is_player:
			change_grav(true)
			
		elif Input.is_action_just_pressed("Grav_Right") and can_act and can_grav and is_player:
			change_grav(false)
			
	#Ink stuff
	if Input.is_action_just_pressed("Ink") and can_act and can_ink and is_player:
		if ink.value >= charge_stab_cost:
			ink.value -= charge_stab_cost
			charge_stab.emit()
			
	#Water stuff
	if (Input.is_action_just_pressed("Water") and can_act and can_water and is_player) or (attack_enemy and can_act and can_water and not is_player):
		if ink.value >= water_cost:
			ink.value -= water_cost
			hide_sprites()
			water.visible = true
			sam.play("Water")
			water_blotch_start.emit()
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
	if can_act and is_player:
		horizontal_direction = Input.get_axis("Left", "Right")
	elif can_act and not is_player:
		if enemy_left:
			horizontal_direction = -1
		elif enemy_right:
			horizontal_direction = 1
			
	if horizontal_direction != 0:
		last_direction = horizontal_direction
	
	var velocityx = get_grav_velocity_x()
	var velocityy = get_grav_velocity_y()
		
	#Get velocityy
	if on_ground:
		cur_jumps = 0
		gravity = min_gravity
		if Input.is_action_just_pressed("Jump") and can_act and is_player:
			cur_jumps += 1
			velocityy = -jump_force
	else:
		if Input.is_action_just_pressed("Jump") and num_jumps > cur_jumps and can_act and is_player:
			cur_jumps += 2
			velocityy = -jump_force
			gravity = min_gravity
		else:
			gravity += gravity_per_second * delta
			velocityy = velocityy + gravity if gravity < max_gravity else max_gravity
		
	#Set speed
	speed += speed_per_second * delta
	
	#Attack stuff
	if (attack_enemy and can_attack and attack_delay<=0 and not is_player): #(Input.is_action_just_pressed("Attack") and can_attack and is_player) or 
		if has_sword > 0:
			hide_sprites()
			sword.visible = true
			can_attack = false
			sam.play("Sword")
			
			if not is_player:
				attack_delay = randf_range(min_enemy_attack_delay, max_enemy_attack_delay)
	elif attack_delay > 0:
		attack_delay -= delta
		
	#Weapon buff stuff
	if (Input.is_action_just_pressed("Repair") and can_act and is_player) or (can_act and has_sword==0 and not is_player):
		print("Hit repair -> ", has_sword)
		
		if (has_sword == Global.black_sword) and (health.value > sword_cost):
			print("has black sword")
			health.value -= sword_cost
			has_sword = Global.red_sword
		elif (has_sword == Global.no_sword) and (ink.value >= sword_cost):
			print("Has no sword")
			ink.value -= sword_cost
			has_sword = Global.black_sword
			can_act = false
			repair_timer.start()
		
	#Set animations
	if horizontal_direction == 0 and can_act and can_attack:
		hide_sprites()
		idle.visible = true
		sam.play("Idle")
	elif horizontal_direction != 0 and can_act and can_attack:
		hide_sprites()
		run.visible = true
		sam.play("Run")
				
	#If changed directions
	if can_act and can_attack and ((horizontal_direction < 0 and sprites.scale.x > 0) or (horizontal_direction > 0 and sprites.scale.x < 0)):
		speed = min_speed
		sprites.scale.x *= -1
		
	#Get velocityx
	if velocityx < 0 and suffer_in_ice_physics:
		velocityx += speed_per_second * delta
		if velocityx > 0:
			velocityx = 0
			suffer_in_ice_physics = false
		velocityx += horizontal_direction * speed
	elif velocityx > 0 and suffer_in_ice_physics:
		velocityx -= speed_per_second * delta
		if velocityx < 0:
			velocityx = 0
			suffer_in_ice_physics = false
		velocityx += horizontal_direction * speed
	
	velocityx = horizontal_direction * speed
	if (velocityx > max_speed) or velocityx < (max_speed * -1):
		velocityx = horizontal_direction * max_speed
		
	set_grav_velocity(velocityx, velocityy)
		
	move_and_slide()

func _on_on_floor_body_entered(body: Node2D) -> void:
	if body != self:
		on_ground = true

func _on_on_floor_body_exited(_body: Node2D) -> void:
	on_ground = false

func _on_sam_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Sword":
		can_attack = true
	elif anim_name == "Water":
		can_act = true

func _on_hitbox_body_entered(_body: Node2D) -> void:
	health.value -= 5
	reset_position()

func _on_hit_body_entered(body: Node2D) -> void:
	if body != self:
		hit_bodies.append(body)

func _on_hit_body_exited(body: Node2D) -> void:
	if body != self:
		hit_bodies.remove_at(hit_bodies.find(body))

func _on_water_spot_body_entered(body: Node2D) -> void:
	if body != self:
		wet_bodies.append(body)
	
func _on_water_spot_body_exited(body: Node2D) -> void:
	if body != self:
		wet_bodies.remove_at(wet_bodies.find(body))

func _on_enemy_left_detection_body_entered(body: Node2D) -> void:
	if body != self:
		enemy_left = true

func _on_enemy_left_detection_body_exited(body: Node2D) -> void:
	if body != self:
		enemy_left = false

func _on_enemy_right_detection_body_entered(body: Node2D) -> void:
	if body != self:
		enemy_right = true

func _on_enemy_right_detection_body_exited(body: Node2D) -> void:
	if body != self:
		enemy_right = false

func _on_enemy_attack_body_entered(body: Node2D) -> void:
	if body != self:
		attack_enemy = true

func _on_enemy_attack_body_exited(body: Node2D) -> void:
	if body != self:
		attack_enemy = false

func _on_repair_timer_timeout() -> void:
	can_act = true

func _on_win_timer_timeout() -> void:
	dead.emit()
