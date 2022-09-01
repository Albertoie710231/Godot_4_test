extends RigidBody3D

var shoot : bool = false

func shoot_trash() -> void:
	get_node("Area3D/CollisionShape3DArea").disabled = false
	get_node(".").set_gravity_scale(0.0)
	get_node(".").set_collision_layer_value(1, false)
	get_node("Area3D").set_collision_layer_value(1, false)
	$Timer.start()
	$Timer2.start()
	shoot = true
	

func _integrate_forces(state) -> void:
	if shoot:
		if $Timer.get_time_left() == 0.0:
			get_node(".").set_collision_layer_value(1, true)
			get_node("Area3D").set_collision_layer_value(1, true)
			get_node("Area3D/CollisionShape3DArea").set_deferred("Disabled", true)
		if $Timer2.get_time_left() == 0.0:
			get_node(".").set_gravity_scale(1.0)
			shoot = false
		state.apply_force(-transform.basis.z * 100, transform.basis.z)
		


func _on_area_3d_body_entered(body):
	if body.is_in_group("Enemy"):
		queue_free()
	elif not body.is_in_group("bodies"):
		get_node(".").set_collision_layer_value(1, true)
		get_node("Area3D").set_collision_layer_value(1, true)
		get_node("Area3D/CollisionShape3DArea").set_deferred("Disabled", true)
		get_node(".").set_gravity_scale(1.0)
		shoot = false
