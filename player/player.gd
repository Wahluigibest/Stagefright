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

var run_max = 300
var run_acc = 14
var jump_speed = -575
var allowed_jumps = 2
var jump_count = 0
var walk_speed = 157.5
var wallkick_speed = Vector2(285, -560)
var gravity = 2000
var friction = 30 
var wallslide_speed = 200
var wallkick_stop_frames = 0.3
var health = 100

#Variables so you can communicate between child nodes, The position node is just so you can flip and rotate the player easily
onready var position2D = $Position2D 
#These signals are to send this info to the Dev HUD
signal Label_change(Name, Value)
#Tracks current player position
signal Position_Info(X, Y)
#Sends HP info to other sprites
signal Health_Info(HP)
#tells other sprites when the player has died
signal death_awww()

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
	var CURRENT_POSITION = get_position()
	
	
	get_input(direction,jump,walk,delta, CURRENT_POSITION)
	move_and_fall(delta)
	#This is so the player moves smoothly up and down slopes, the true is so the player stops on slopes
	VELOCITY.y = move_and_slide_with_snap(VELOCITY, SNAP_VECTOR, 
			FLOOR_NORMAL, true, 4, SLOPE_THERSHOLD).y 
	if is_on_floor() and SNAP_VECTOR == Vector2.ZERO:
		reset_snap()
	if is_on_floor():
		jump_count = 0
	local_hold_time -= delta

func move_and_fall(delta):
	VELOCITY.y += gravity * delta
	if is_near_wall(): #This clamp allows for the wall slide effect where you're slowly sliding down a wall so you have more time to wall kick
		VELOCITY.y = clamp(VELOCITY.y, jump_speed, wallslide_speed)

func get_input(direction,jump,walk,delta, CURRENT_POSITION):
	if jump:
		if jump_count < allowed_jumps:
			#Setting the snap vector to zero here allows the players to jump instead of being glued to the floor
			SNAP_VECTOR = Vector2.ZERO
			VELOCITY.y = jump_speed
			jump_count += 1
		#This is for wallkicks, the player senses ceilings as walls due the fact the sensor is at 135 degrees
		#So there is a checker to make sure you can't wallkick off of ceils
		if is_near_wall() and !is_near_ceiling():
			if Input.is_action_pressed("jump") and (Input.is_action_pressed("move_left") and direction < 0) or (Input.is_action_pressed("move_right") and direction > 0):
				#It felt clunky at the beginning because you would quickly turn around from your left input, 
				#so there's a no move timer to ensure you move a bit
				NO_MOVE_HORIZONTAL_TIME = wallkick_stop_frames
				VELOCITY.x = wallkick_speed.x * -direction
				VELOCITY.y = -1000
				jump_count -= 1
	
	if direction != 0:
		#Turn around and move
		position2D.scale.x = direction * 1
		#The wall checker detects any walls in front of the player but also needs to not detect any slopes
		#All of the slopes are 45 degrees so we use 135 degrees to ensure it never touches slopes
		$Wallchecker.rotation_degrees = 135 * -direction
		#print(NO_MOVE_HORIZONTAL_TIME)
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
	Label_print(direction)
	bottomless_pit_check(CURRENT_POSITION)

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
			emit_signal("Label_change", "AnimationLabel", "Current animation: Land")
			falling_ani = false
		if direction != 0:
			if abs(VELOCITY.x) > run_max * 0.70 and !walk:
				$AnimationTree["parameters/state/current"] = States.RUN
				emit_signal("Label_change", "AnimationLabel", "Current animation: Run")
				$AnimationTree["parameters/run_timescale/scale"] = abs(VELOCITY.x) / 115
			elif walk:
				$AnimationTree["parameters/state/current"] = States.WALK
				emit_signal("Label_change", "AnimationLabel", "Current animation: Walk")
				$AnimationTree["parameters/walk_timescale/scale"] = abs(VELOCITY.x) / 55
		else:
			$AnimationTree["parameters/state/current"] = States.IDLE
			emit_signal("Label_change", "AnimationLabel", "Current animation: Idle")
		if jump:
			$AnimationTree["parameters/jump/active"] = true
			emit_signal("Label_change", "AnimationLabel", "Current animation: Jump")
	elif VELOCITY.y < 1600:
		$AnimationTree["parameters/state/current"] = States.FALL
		emit_signal("Label_change", "AnimationLabel", "Current animation: Fall")
	if  is_near_wall():
		$AnimationTree["parameters/state/current"] = States.WALLSLIDE
		emit_signal("Label_change", "AnimationLabel", "Current animation: Wallslide")

func Label_print(direction):
	emit_signal("Label_change", "VelocityLabel", "VELOCITY: " + str(VELOCITY))
	emit_signal("Label_change", "JumpLabel", str(allowed_jumps - jump_count))
	if is_on_floor():
		emit_signal("Label_change", "FloorLabel", "On Floor")
	else:
		emit_signal("Label_change", "FloorLabel", "In Air")
	
	if is_near_wall():
		emit_signal("Label_change", "WallLabel", "On Wall")
	else:
		emit_signal("Label_change", "WallLabel", "Away From Wall")
	
	if is_near_ceiling():
		emit_signal("Label_change", "CeilingLabel", "On Ceiling")
	else:
		emit_signal("Label_change", "CeilingLabel", "Away from Ceiling")
	
	if direction > 0:
		emit_signal("Label_change", "DirectionLabel", "Moving Right!")
	elif direction < 0:
		emit_signal("Label_change", "DirectionLabel", "Moving Left!")
	elif !direction:
		emit_signal("Label_change", "DirectionLabel", "No Movement")
	

func bottomless_pit_check(CURRENT_POSITION):
	emit_signal("Position_Info", CURRENT_POSITION.x, CURRENT_POSITION.y)
	if CURRENT_POSITION.y > 4000:
		health -= 20
		#print(health)
		emit_signal("Health_Info", health)
		self.position = Vector2(90, 550.027771)
	if health == 0 or health < 0:
		emit_signal("death_awww")
		print("emited!")


func _on_Death_Screen_Unpause_tree():
	health = 100
	emit_signal("Health_Info", health)
