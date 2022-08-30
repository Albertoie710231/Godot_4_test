extends RigidDynamicBody3D

var shoot : bool = false

func shoot_trash() -> void:
	get_node("Area3D/CollisionShape3DArea").disabled = false
	get_node(".").set_gravity_scale(0.0)
	get_node(".").set_collision_layer_value(1, false)
	get_node("Area3D").set_collision_layer_value(1, false)
	shoot = true
	

func _physics_process(delta):
	if shoot:
		apply_force(-transform.basis.z * delta * 10000, transform.basis.z)
		


func _on_area_3d_body_entered(body):
	if body.is_in_group("Enemie"):
		queue_free()
	else:
		get_node(".").set_gravity_scale(1.0)
		get_node(".").set_collision_layer_value(1, true)
		get_node("Area3D").set_collision_layer_value(1, true)
		get_node("Area3D/CollisionShape3DArea").set_deferred("Disabled", true)
		shoot = false
