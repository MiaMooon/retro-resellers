extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const CROUCH_SPEED = 2.5
const JUMP_VELOCITY = 4.8
const SENSITIVITY = 0.004

# Crouch state
var is_crouching = false
const HEAD_STAND_Y = 1.6
const HEAD_CROUCH_Y = 1.0
const CROUCH_TRANSITION_SPEED = 6.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

@onready var head = $Head
@onready var camera = $Head/Camera3D

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	# Toggle crouch
	if Input.is_action_just_pressed("Crouch"):
		is_crouching = !is_crouching

	# Smoothly move head for crouch effect
	var target_y = HEAD_CROUCH_Y if is_crouching else HEAD_STAND_Y
	head.position.y = lerp(head.position.y, target_y, delta * CROUCH_TRANSITION_SPEED)

	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Allow jumping even while crouching
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Speed logic
	if is_crouching:
		speed = CROUCH_SPEED
	elif Input.is_action_pressed("Sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Handle movement
	var input_dir := Input.get_vector("Game_Left", "Game_Right", "Game_Forward", "Game_Backward")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
