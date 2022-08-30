extends CharacterBody3D


const SPEED = 7.0
const JUMP_VELOCITY = 7.0

var inertia : float = 30.0
var air_time : float = 0.0
var jump_velocity : float = 0.0
var wall_flag : bool = false
var sweep_mode_flag : bool = false
var wall_normal : Vector3 = Vector3.ZERO
# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

enum player_state{
	IDLE,
	MOVEMENT,
	JUMP,
	DOUBLE_JUMP,
	FALL,
	WALL_WALK
}

var state = player_state.IDLE

@onready var _principal_pivot_camera : Node3D = $"../PrincipalSpringArm"
@onready var _model : Node3D = $Pivot
@onready var _timer : Timer = $Timer
@onready var _pivot_remote_transform : Node3D = $PivotRemoteTransform

var double_jump_flag : bool = false

func _process(_delta):
	if not sweep_mode_flag:
		_pivot_remote_transform.rotation.y = _model.rotation.y
	else:
		_model.rotation.y = _pivot_remote_transform.rotation.y

func _physics_process(delta:float) -> void:
	movement(delta)
	if velocity == Vector3.ZERO:
		state = player_state.IDLE
	elif velocity.y < 0.2:
		state = player_state.MOVEMENT
	
	#print(player_state.keys()[state])
	move_and_slide()
	
	if is_on_floor():
		for index in get_slide_collision_count():
			var collision = get_slide_collision(index)
			if collision.get_collider().is_in_group("bodies") and collision.get_normal().y < 0.9:
				collision.get_collider().apply_central_impulse(-collision.get_normal() * delta * inertia)
				#print(collision.get_normal())

func wall_run() -> void:
	if wall_flag:
		var normal_wall = get_wall_normal()
		velocity = -normal_wall
		#print(normal_wall)

func movement(delta:float) -> void:
	if is_on_floor():
		air_time = 0.0
		if double_jump_flag:
			double_jump_flag = false
		# Handle Jump.
		if Input.is_action_just_pressed("jump"):
			state = player_state.JUMP
			_timer.start()
			velocity.y = JUMP_VELOCITY
			double_jump_flag = true
	elif not is_on_floor():
		air_time += delta
		velocity.y -= gravity * delta
		#print(air_time)
		#print(velocity)
		if double_jump_flag and air_time > 0.2:
			double_jump()
		if velocity.y <= 0.0:
			state = player_state.FALL
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (_principal_pivot_camera.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		var look_direction = Vector2(-velocity.z, -velocity.x)
		_model.rotation.y = lerp_angle(_model.rotation.y,look_direction.angle(),0.5)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func double_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		state = player_state.DOUBLE_JUMP
		velocity.y = JUMP_VELOCITY
		print("double_jump")
		double_jump_flag = false


func _on_timer_timeout() -> void:
	wall_flag = false


func _on_sweeper_sweep_signal():
	sweep_mode_flag = !sweep_mode_flag
