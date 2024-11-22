extends Area2D

@onready var paint: AnimatedSprite2D = %Paint
@onready var lifetime: Timer = %Lifetime

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	paint.play("attack")
	
	#TODO: Handle enemies in Hit_Box

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	paint.self_modulate.a = lifetime.time_left * (1/float(lifetime.wait_time))

func _on_timer_timeout() -> void:
	self.queue_free()
