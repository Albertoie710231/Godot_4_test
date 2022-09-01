extends Node3D

func _on_area_3d_body_exited(body):
	if body.get_class() == "RigidBody3D":
		body.set_linear_velocity(Vector3.ZERO)
		body.set_angular_velocity(Vector3.ZERO)
		body.set_constant_force(Vector3.ZERO)
	body.global_transform.origin = Vector3(0,3,0)
