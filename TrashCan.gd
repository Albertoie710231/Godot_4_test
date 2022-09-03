extends RigidBody3D

var shoot : bool = false

@onready var own_collision = $Area3D

func restore_rigid_body() -> void:
	get_node(".").set_collision_layer_value(1, true)
	get_node(".").set_collision_layer_value(2, true)
	get_node("Area3D").set_collision_layer_value(1, true)
	get_node("Area3D/CollisionShape3DArea").set_deferred("Disabled", true)
	get_node(".").set_gravity_scale(1.0)

func shoot_trash() -> void:
	get_node("Area3D/CollisionShape3DArea").disabled = false
	get_node(".").set_gravity_scale(0.0)
	get_node(".").set_collision_layer_value(1, false)
	get_node(".").set_collision_layer_value(2, false)
	get_node("Area3D").set_collision_layer_value(1, false)
	if Input.get_connected_joypads():
		Input.start_joy_vibration(0, 1.0, 1.0, 0.07)
	$Timer.start()
	shoot = true
	

func _integrate_forces(state) -> void:
	if shoot:
		#if state.get_angular_velocity().length() < 0.0001:
			#print(state.get_angular_velocity())
		if $Timer.get_time_left() == 0.0 or state.get_angular_velocity().length() > 0.0001:
			restore_rigid_body()
			shoot = false
		state.apply_force(-transform.basis.z * 250, transform.basis.z)
		

func _on_area_3d_body_entered(body):
	if body.is_in_group("Enemy"):
		queue_free()
	elif body.get_parent().get_name() == "World": 
		#if body.get_parent().get_name() != "Sweeper":
		#print(body.get_parent().get_name())
		restore_rigid_body()
		shoot = false
