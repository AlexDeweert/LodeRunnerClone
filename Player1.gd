extends KinematicBody2D

var velocity = Vector2.ZERO

const UP = Vector2(0,-1)
const H_SPEED = 150
const V_SPEED = 150
const ACCEL = 25
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
var rand = false
var onRope = false
var midLadder = false

signal player_fired_focus_beam_right
signal player_fired_focus_beam_left

### TODO: Center the player sprite when onLadder and climbing UP

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Player1._ready()")

func _physics_process(_delta):
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
	if Input.is_action_pressed("ui_down"):
		#ladder top stands
		set_collision_layer_bit(1,false)
		if onRope:
			#rope walks
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
#	if !onLadder and !ifoLadder:
	#This used to fix some kind of bug but we can't probably remove
	if !onLadder and !midLadder:
		motion.y = GRAVITY
		#falling, could set a var here for later
		if !is_on_floor():
			falling = true

	#Apply the motion vector to the results of processing w/move_and_slide
	motion = move_and_slide(motion,UP)
	
	#handle firing left or right
	if Input.is_action_just_pressed("ui_focus_prev"):
		if isApproxWithinTileCenter():
			emit_signal("player_fired_focus_beam_right")

	elif Input.is_action_just_pressed("ui_focus_next"):
		if isApproxWithinTileCenter():
			emit_signal("player_fired_focus_beam_left")
	
	#We fell through ladder top (which is on the ladder layer at position 1)
	#and we want to reset the ability to stand on it again
	if !get_collision_layer_bit(1):
		set_collision_layer_bit(1,true)
	
	#If we're on the floor clearly we're not falling.
	#at the moment this is only used to test if we need to
	#reset the rope "trap door", useful to grab the rope again
	#if dropping from rope to rope.
	if is_on_floor():
		falling = false
	
	#We're resetting the rope "trap door" so that they can re-fall
	#through after the collision layer bit is reset.
	if falling:
		set_collision_layer_bit(2,true)

#A note on get_slide_count(), this will display the number of collisions
#calculated at the last call to move_and_slide. The number of collisions
#can be of course, greater than 1 for example, in a corner, but if the player
#CHANGES DIRECTION, then a collision will be counted with the same object.
#So in the case of FLAT GROUND moving left and right will generate multiple
#collisions. Then we only need to calculate the first collision.
func getSlideCollisions():
#	var collisions = []
	var numCollisions = get_slide_count()
#	print("collisions detected %s"%numCollisions)
#	for i in get_slide_count():
#		collisions.append(get_slide_collision(i))
	return numCollisions

#This makes it so the player can't disintegrate the ground unless they are
#reasonably within the center of a tile. Prevents disintegrating a tile that
#that the player is standing on
func isApproxWithinTileCenter():
	var result = fmod(position.x,32)
	result -= 16.0
	result = abs(result)
	if result <= 10: return true
	return false

func _on_Ladder_body_shape_entered(_body_id, body, _body_shape, area_shape):
	if self.name == body.name:
		ifoLadder = true
	
func _on_Ladder_body_shape_exited(_body_id, body, _body_shape, _area_shape):
	if self.name == body.name:
		ifoLadder = false
		onLadder = false

func _on_GrabbingRope_body_shape_entered(_body_id, _body, _body_shape, _area_shape):
	onRope = true

func _on_GrabbingRope_body_shape_exited(_body_id, _body, _body_shape, _area_shape):
	onRope = false


func _on_MidLadder_body_shape_entered(_body_id, body, _body_shape, _area_shape):
	if self.name == body.name:
		midLadder = true

func _on_MidLadder_body_shape_exited(_body_id, body, _body_shape, _area_shape):
	if self.name == body.name:
		midLadder = false
