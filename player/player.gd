class_name Player
extends KinematicBody2D

# Keep this in sync with the AnimationTree's state names and numbers.
enum States {
	IDLE = 0,
	WALK = 1,
	RUN = 2,
	FLY = 3,
	FALL = 4,
	WALLSLIDE = 5,
}

#NEVER TOUCH THESE VARIABLES, THEY ARE ALL ESSENTIAL TO THE PHYSICS WORKING
var VELOCITY = Vector2.ZERO
const FLOOR_NORMAL = Vector2.UP 
const SNAP_DIRECTION = Vector2.DOWN
const SNAP_LENGTH = 32.0
const SLOPE_THERSHOLD = deg2rad(46)

#No move horizontal ensures the player can not use the left or right inputs to move in some cases like after wallkicking or hitstun
var NO_MOVE_HORIZONTAL_TIME = 0.0
#This variable is to make sure you don't snap where you jump and you can apply vertical force 
var SNAP_VECTOR = SNAP_DIRECTION * SNAP_LENGTH

var run_max = 350
var run_acc = 28
var jump_speed = -800
var walk_speed = 157.5
var wallkick_speed = 285
var gravity = 2000
var friction = 30 

#Variables so you can communicate between child nodes, The position node is just so you can flip and rotate the player easily
onready var position2D = $Position2D 
#These labels are temporaries until I find out how to make UI
onready var Ceiling_Label = $CeilingLabel
onready var Velocity_label = $VelocityLabel
onready var Floor_label = $FloorLabel
onready var Direction_Label = $DirectionLabel
onready var Animation_Label = $AnimationLabel
onready var Wall_Label = $WallLabel

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
	
	get_input(direction,jump,walk,delta)
	move_and_fall(delta)
	#This is so the player moves smoothly up and down slopes, the true is so the player stops on slopes
	VELOCITY.y = move_and_slide_with_snap(VELOCITY, SNAP_VECTOR, 
			FLOOR_NORMAL, true, 4, SLOPE_THERSHOLD).y 
	if is_on_floor() and SNAP_VECTOR == Vector2.ZERO:
		reset_snap()
	local_hold_time -= delta

func move_and_fall(delta):
	VELOCITY.y += gravity * delta
	if is_near_wall(): #This clamp allows for the wall slide effect where you're slowly sliding down a wall so you have more time to wall kick
		VELOCITY.y = clamp(VELOCITY.y, jump_speed, 200)

func get_input(direction,jump,walk,delta):
	if is_on_floor():
		if jump:
			#Setting the snap vector to zero here allows the players to jump instead of being glued to the floor
			SNAP_VECTOR = Vector2.ZERO
			VELOCITY.y = jump_speed
			#The hold is so you can't jump infinite times
			local_hold_time = jump_hold_time
		elif local_hold_time > 0:
			if jump:
				VELOCITY.y = jump_speed
			else:
				local_hold_time = 0
	else:
		#This is for wallkicks, the player senses ceilings as walls due the fact the sensor is at 135 degrees
		#So there is a checker to make sure you can't wallkick off of ceils
		if is_near_wall() and !is_near_ceiling():
			if Input.is_action_pressed("jump") and (Input.is_action_pressed("move_left") and direction < 0) or (Input.is_action_pressed("move_right") and direction > 0):
				#It felt clunky at the beginning because you would quickly turn around from your left input, 
				#so there's a no move timer to ensure you move a bit 
				NO_MOVE_HORIZONTAL_TIME = 0.3
				VELOCITY.x = wallkick_speed * -direction
				VELOCITY.y = jump_speed * 0.7
	
	if direction != 0:
		#Turn around and move
		position2D.scale.x = direction * 1
		#The wall checker detects any walls in front of the player but also needs to not detect any slopes
		#All of the slopes are 45 degrees so we use 135 degrees to ensure it never touches slopes
		$Wallchecker.rotation_degrees = 135 * -direction
		print(NO_MOVE_HORIZONTAL_TIME)
		#Adds all effects so you can accelerate
		if NO_MOVE_HORIZONTAL_TIME > 0.0:
			NO_MOVE_HORIZONTAL_TIME -= delta
		else:
			if walk:
				VELOCITY.x = walk_speed * direction 
			else:
					VELOCITY.x = move_toward(VELOCITY.x, run_max * direction, run_acc)
	else:
		#Stop moving and apply friction
		VELOCITY.x = move_toward(VELOCITY.x, 0, friction)
	animation(direction, jump, walk)
	

func reset_snap():
	SNAP_VECTOR = SNAP_DIRECTION * SNAP_LENGTH

func is_near_wall():
	return $Wallchecker.is_colliding()

func is_near_ceiling():
	return $Ceilingchecker.is_colliding()

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
	if  is_near_wall():
		$AnimationTree["parameters/state/current"] = States.WALLSLIDE
		Animation_Label.text = "Current animation: Wallslide"

func Label_print(direction):
	Velocity_label.text = "VELOCITY: " + str(VELOCITY)
	
	if is_on_floor():
		Floor_label.text = "On Floor" 
	else:
		Floor_label.text = "In air"
	
	if is_near_wall():
		Wall_Label.text = "On Wall"
	else:
		Wall_Label.text = "Away from wall"
	
	if is_near_ceiling():
		Ceiling_Label.text = "Touching Ceiling"
	else:
		Ceiling_Label.text = "Away from ceiling"
	
	if direction > 0:
		Direction_Label.text = "Moving? Right!"
	elif direction < 0:
		Direction_Label.text = "Moving? Left!"
	elif !direction:
		Direction_Label.text = "Not Moving"
