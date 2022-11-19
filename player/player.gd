class_name Player
extends KinematicBody2D

# Keep this in sync with the AnimationTree's state names and numbers.
enum States {
	IDLE = 0,
	WALK = 1,
	RUN = 2,
	FLY = 3,
	FALL = 4,
}


var VELOCITY = Vector2.ZERO
const FLOOR_NORMAL = Vector2.UP 
const SNAP_DIRECTION = Vector2.DOWN
const SNAP_LENGTH = 32.0
const SLOPE_THERSHOLD = deg2rad(46)
var NO_MOVE_HORIZONTAL_TIME = 0.0
#This variable is to make sure you don't snap where you jump and you can apply vertical force 
var SNAP_VECTOR = SNAP_DIRECTION * SNAP_LENGTH

var run_max = 350
var run_acc = 28
var jump_speed = -800
var gravity = 2000
var friction = 30 

#variables so you can communicate between child nodes
onready var sprite = $Sprite
onready var sprite_scale = sprite.scale.x

onready var Velocity_label = $VelocityLabel
onready var Floor_label = $FloorLabel
onready var Direction_Label = $DirectionLabel
onready var Animation_Label = $AnimationLabel

var jump_hold_time = 0.2
var local_hold_time = 0
var falling_ani = false

func _ready():
	$AnimationTree.active = true

func _physics_process(delta):
#Setting up variables, they must stay in a function
	#the absolute volume is to make sure it only plays when the player falls from a height taller than their jumping height
	if abs(jump_speed) < VELOCITY.y and 0 < VELOCITY.y:
		falling_ani = true
	var direction = sign(Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) 
	var jump = Input.is_action_just_pressed("jump")
	var walk = Input.get_action_strength("walk")
	
	get_input(direction,jump,walk)
	VELOCITY.y += gravity * delta
	#This is so the player moves smoothly up and down slopes, the true is so the player stops on slopes
	VELOCITY.y = move_and_slide_with_snap(VELOCITY, SNAP_VECTOR, 
			FLOOR_NORMAL, true, 4, SLOPE_THERSHOLD).y 
	if is_on_floor() and SNAP_VECTOR == Vector2.ZERO:
		reset_snap()
	local_hold_time -= delta
	Label_print(direction)

func get_input(direction,jump,walk):
	if is_on_floor():
		if jump:
			SNAP_VECTOR = Vector2.ZERO
			VELOCITY.y = jump_speed
			#The hold is so you can't jump infinite times
			local_hold_time = jump_hold_time
	elif local_hold_time > 0:
		if jump:
			VELOCITY.y = jump_speed
		else:
			local_hold_time = 0
	if direction != 0:
		#Turn around and move
		sprite.transform.x = direction * Vector2(sprite_scale, 0)
		#Adds all effects so you can accelerate
		if walk:
			VELOCITY.x = run_max * direction * 0.45
		else:
			VELOCITY.x = move_toward(VELOCITY.x, run_max * direction, run_acc)
	else:
		#Stop moving and apply friction
		VELOCITY.x = move_toward(VELOCITY.x, 0, friction)
	animation(direction, jump, walk)
	
func reset_snap():
	SNAP_VECTOR = SNAP_DIRECTION * SNAP_LENGTH

func animation(direction, jump, walk):
	# Check if on floor and do mostly animation stuff based on it.
	if is_on_floor():
		if falling_ani:
			$AnimationTree["parameters/land/active"] = true
			Animation_Label.text = "Current animation: Land"
			falling_ani = false
		if direction != 0:
			if abs(VELOCITY.x) > run_max * 0.70 and !walk:
				$AnimationTree["parameters/state/current"] = States.RUN
				Animation_Label.text = "Current animation: Run"
				$AnimationTree["parameters/run_timescale/scale"] = abs(VELOCITY.x) / 115
			elif walk:
				$AnimationTree["parameters/state/current"] = States.WALK
				Animation_Label.text = "Current animation: Walk"
				$AnimationTree["parameters/walk_timescale/scale"] = abs(VELOCITY.x) / 55
		else:
			$AnimationTree["parameters/state/current"] = States.IDLE
			Animation_Label.text = "Current animation: Idle"
		if jump:
			$AnimationTree["parameters/jump/active"] = true
			Animation_Label.text = "Current animation: Jump"
	elif VELOCITY.y < 1600:
		$AnimationTree["parameters/state/current"] = States.FALL
		Animation_Label.text = "Current animation: Fall"

func Label_print(direction):
	var spaces = subTxt("     ", multTxt(" ", str(VELOCITY).length()))
	Velocity_label.text = "VELOCITY:" + spaces + str(VELOCITY)
	print(VELOCITY.y)
	
	if is_on_floor():
		Floor_label.text = "On Floor"
	else:
		Floor_label.text = "In air"
	
	if direction > 0:
		Direction_Label.text = "Moving? Right!"
	elif direction < 0:
		Direction_Label.text = "Moving? Left!"
	elif !direction:
		Direction_Label.text = "Not Moving"

func multTxt(txt, nb):
	var newText = ""
	for _i in range(nb):
		newText += txt
	return newText

func subTxt(txt1, txt2):
	var newSize = txt1.length()-txt2.length()
	return txt1.substr(0, newSize)
