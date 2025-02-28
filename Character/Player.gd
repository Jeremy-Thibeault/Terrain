extends CharacterBody3D

@export var toggle_gravity:bool = true

const walkSpeed = 5.0
const jumpSpeed = 4.5
const moveAccel = 0.1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var lookat
var lastLookatDirection : Vector3

var moveSpeed = 0.0
var lastMoveSpeed = 0.0

func _ready():
	lookat = get_tree().get_nodes_in_group("CameraController")[0].get_node("LookAt")
	lastMoveSpeed = 0.0
	if not toggle_gravity:
		gravity = 0

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jumpSpeed


	if Input.is_action_pressed("Sprint"):
		moveSpeed = lerp(lastMoveSpeed, walkSpeed * 1.5, moveAccel)
	else:
		moveSpeed = lerp(lastMoveSpeed, walkSpeed, moveAccel)


	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("Strafe_Left", "Strafe_Right", "Forward", "Back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		var lerpDirection = lerp(
			lastLookatDirection,
			Vector3(
				lookat.global_position.x, 
				global_position.y, 
				lookat.global_position.z),
			 .1)
		
		look_at(lerpDirection)
		
		lastLookatDirection = lerpDirection

		velocity.x = direction.x * moveSpeed
		velocity.z = direction.z * moveSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, moveSpeed)
		velocity.z = move_toward(velocity.z, 0, moveSpeed)
		
	lastMoveSpeed = moveSpeed
	
	# Handle Animation States
	$ATree.set("parameters/conditions/run", 
		Input.is_action_pressed("Sprint") 
		&& input_dir != Vector2.ZERO 
		&& is_on_floor())
	$ATree.set("parameters/conditions/runstop",
		Input.is_action_just_released("Sprint")
		&& is_on_floor())
	$ATree.set("parameters/conditions/walk", 
		input_dir != Vector2.ZERO
		&& !Input.is_action_pressed("Sprint")
		&& is_on_floor())
	$ATree.set("parameters/conditions/idle", 
		input_dir == Vector2.ZERO 
		&& is_on_floor())
	$ATree.set("parameters/conditions/jump",
		!is_on_floor())
	
	
	move_and_slide()
