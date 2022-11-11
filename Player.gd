extends KinematicBody
class_name Player

const GRAVITY = -30
const MAX_SPEED = 5
const JUMP_SPEED = 10
const ACCELERATION = 1
const DEACCELERATION = 6
const MAX_SLOPE_ANGLE = 40

var MOUSE_SENSITIVITY = 0.05
var direction = Vector3()
var velocity = Vector3()
var snap_vector = Vector3.ZERO


onready var camera = $CameraPivot/Camera
onready var rotation_helper = $CameraPivot


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)

func process_input(delta):
	# Walking
	direction = Vector3()
	var camera_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("ui_up"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("ui_down"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("ui_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_movement_vector.x += 1
#
	input_movement_vector = input_movement_vector.normalized()

	# Basis vectors are already normalized.
	direction += -camera_xform.basis.z * input_movement_vector.y
	direction += camera_xform.basis.x * input_movement_vector.x
	# ----------------------------------

	# ----------------------------------
	# Jumping
	if is_on_floor():
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_SPEED
			snap_vector = Vector3.ZERO
		else:
			snap_vector = -get_floor_normal()

	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func process_movement(delta):
	direction.y = 0
	direction = direction.normalized()

	velocity.y += delta * GRAVITY

	var hvelocity = velocity
	hvelocity.y = 0

	var target = direction
	target *= MAX_SPEED

	var acceleration
	if direction.dot(hvelocity) > 0:
		acceleration = ACCELERATION
	else:
		acceleration = DEACCELERATION

	hvelocity = hvelocity.linear_interpolate(target, acceleration * delta)
	velocity.x = hvelocity.x
	velocity.z = hvelocity.z
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, false, 4, rad2deg(MAX_SLOPE_ANGLE))

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rotation = rotation_helper.rotation_degrees
		camera_rotation.x = clamp(camera_rotation.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rotation
