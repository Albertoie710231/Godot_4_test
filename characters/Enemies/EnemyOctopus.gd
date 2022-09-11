extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var move_dir = Vector2.ZERO
var timeout_flag = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= (gravity/6.0) * delta
		
	if transform.origin.y < 5.0:
		velocity.y = 2.0

	# Handle Jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if timeout_flag:
		move_dir = Vector2(randf_range(-1.0,1.0),randf_range(-1.0,1.0))
		timeout_flag = false
		
	var direction = (transform.basis * Vector3(move_dir.x, 0, move_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _on_area_3d_body_entered(body):
	#if body
	pass


func _on_timer_timeout():
	timeout_flag = true
