extends KinematicBody2D

var velocity = Vector2.ZERO

const UP = Vector2(0,-1)
const H_SPEED = 100
const V_SPEED = 100
const ACCEL = 25
const GROUND_FRICTION = 100
const GRAVITY = 200


enum FACING {LEFT,RIGHT}

var motion = Vector2()
var doubleJump = false
var facing = FACING.LEFT
var lives = 5

var ifoLadder = false
var onLadder = false
var onLadderTop = false
var falling = false

var onRope = false

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Player1._ready()")

#Place an underscore ifo parameters if they're not being used
#and that gets rid of warnings for unused parameters
func _physics_process(_delta):
	
	handleFocusBeamInput()
	
	#If standing in front of the ladder but NOT on it
	if ifoLadder:
		#Pressing down we put the player on the ladder and start moving down
		if Input.is_action_pressed("ui_down"):
			if !onLadder:
				onLadder = true
			motion.y = V_SPEED
		#Pressing up we do the same thing but move upwards
		elif Input.is_action_pressed("ui_up"):
			if !onLadder:
				onLadder = true
			motion.y = -V_SPEED
		
		#On ladder and not pressing up or down we stop movement
		#essentially grabbing into the ladder b/c otherwise we fall
		#or continue to rise like an elevator
		elif !is_on_floor():
			if !onLadder:
				onLadder = true
			motion.y = 0

	#If we're not in the front of a ladder but we're pressing DOWN
	#then we must allow our player to drop through the top of a ladder
	#since players can stand on top of a ladder once they reach the top
	elif Input.is_action_pressed("ui_down"):
		set_collision_layer_bit(1,false)
		if onRope:
			set_collision_layer_bit(2,false)

	#If the player is on the floor OR on the ladder they can move left and right
	if is_on_floor() or onLadder:
		if Input.is_action_pressed("ui_right"):
			facing = FACING.RIGHT
			motion.x = H_SPEED
				
		elif Input.is_action_pressed("ui_left"):
			facing = FACING.LEFT
			motion.x = -H_SPEED
		else:
			motion.x = lerp(motion.x,0,0.75)
	
	else:
		motion.x = 0
	
	# Only apply gravity when we're not holding on to a ladder
	# also if we fall through the ladder stand (on top) we also
	# need to catch the ladder, so if we're ifo ladder no grav
	if !onLadder and !ifoLadder:
		motion.y = GRAVITY
		#falling, could set a var here for later
		if !is_on_floor():
			pass
	
	#Experimentation
	
	#Apply the motion vector to the results of processing w/move_and_slide
	motion = move_and_slide(motion,UP)
	
	#We fell through ladder top (which is on the ladder layer at position 1)
	#and we want to reset the ability to stand on it again
	if !get_collision_layer_bit(1):
		set_collision_layer_bit(1,true)
	
	#We're resetting the rope "trap door" so that they can re-fall
	#through after the collision layer bit is reset. This works for now
	#but this won't work if the player falls from rope-to-rope. Instead
	#we might need to do a mid-air reset IF the player is falling AND 
	#not onRope
	if is_on_floor():
		set_collision_layer_bit(2,true)

#Mapped to Q and E, these are fire buttons for disintegrating the ground
#to the left and the right. Doesn't work on all tiles, usually only
#desctructable ground tiles
func handleFocusBeamInput():
	if Input.is_action_just_pressed("ui_focus_prev"):
		print("firedRight")
		
	elif Input.is_action_just_pressed("ui_focus_next"):
		print("firedLeft")

func _on_Ladder_body_shape_entered(_body_id, body, _body_shape, _area_shape):
	if self.name == body.name:
		ifoLadder = true
	
func _on_Ladder_body_shape_exited(_body_id, body, _body_shape, _area_shape):
	if self.name == body.name:
		ifoLadder = false
		onLadder = false

func _on_GrabbingRope_body_shape_entered(_body_id, _body, _body_shape, _area_shape):
	onRope = true
	print("grabbingRope")

func _on_GrabbingRope_body_shape_exited(_body_id, _body, _body_shape, _area_shape):
	onRope = false
	print("stopped grabbingRope")
