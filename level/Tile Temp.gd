extends KinematicBody2D

onready var Starttimer = $Starttimer
onready var Resettimer = $Resettimer
var is_triggered = false

export var reset_time : float = 1.0

var velocity = Vector2()
var Gravity = 1000

onready var reset_position = global_position

func _ready():
	set_physics_process(false)

func collide_with(collision: KinematicCollision2D, collider : KinematicBody2D):
	if !is_triggered:
		is_triggered = true
		Starttimer.start()
		velocity = Vector2.ZERO
 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity.y += Gravity * delta
	position += velocity * delta


func _on_Starttimer_timeout():
	set_physics_process(true)
	Resettimer.start(reset_time)

func _on_Resettimer_timeout():
	set_physics_process(false)
	yield(get_tree(), "physics_frame")
	var temp = collision_layer
	collision_layer = 0
	global_position = reset_position
	yield(get_tree(), "physics_frame")
	collision_layer = temp
	is_triggered = false
