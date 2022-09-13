extends CharacterBody3D

@export var health = 30.0

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

enum {
	IDLE,
	ATTACK,
	STUNNED
}

var state = IDLE

@onready var _vision = $Area3d/CollisionShape3d

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var move_dir = Vector2.ZERO
var timeout_flag = false

func _process(_delta):
	match state:
		IDLE:
			pass
		ATTACK:
			pass
		STUNNED:
			pass

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= (gravity/6.0) * delta
		
	if $RayCast3d.is_colliding():
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
	if get_last_slide_collision():
		if get_last_slide_collision().get_class() == "KinematicCollision3D":
			if get_last_slide_collision().get_travel() != Vector3.ZERO and $Timer2.get_time_left() == 0.0:
				state = STUNNED
				health -= 10
				print(health)
				$Timer2.start()
	
	if health <= 0.0:
		queue_free()


func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		state = ATTACK


func _on_timer_timeout():
	timeout_flag = true


func _on_area_3d_body_exited(body):
	if body.is_in_group("Player"):
		state = IDLE
