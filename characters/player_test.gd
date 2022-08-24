extends RigidDynamicBody3D

@export var speed := 5.0
@export var jump_strength := 5.0
@export var number_jumps := 1
@export var mouse_sensitivity := 0.001

@onready var _model = $Pivot
@onready var _principal_pivot_camera = $PrincipalSpringArm
@onready var _ground_ray_cast = $RayCast3D

var _current_jump := 0
var _air_time := 0.0
var is_jumping := false

func _physics_process(delta: float) -> void:
	air_time(delta)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	character_movement(state)

func character_movement(state: PhysicsDirectBodyState3D) -> void:
	
	if _ground_ray_cast.is_colliding() and _air_time > 0.1:
		is_jumping = false
		_current_jump = 0
	
	if Input.is_action_just_pressed("jump") and _current_jump < number_jumps:
		is_jumping = true
		_current_jump += 1
		
		if state.linear_velocity.y < jump_strength:
			state.linear_velocity.y = 0.0
			
		state.apply_central_impulse(Vector3.UP * jump_strength)
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (_principal_pivot_camera.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		state.linear_velocity.x = direction.x * speed
		state.linear_velocity.z = direction.z * speed
		var look_direction = Vector2(-state.linear_velocity.z, -state.linear_velocity.x)
		_model.rotation.y = lerp_angle(_model.rotation.y,look_direction.angle(),0.5)
	else:
		state.linear_velocity.x = move_toward(state.linear_velocity.x, 0, speed)
		state.linear_velocity.z = move_toward(state.linear_velocity.z, 0, speed)

func air_time(delta: float) -> void:
	if is_jumping:
		_air_time += delta
	else:
		_air_time = 0.0
