extends Node3D



func _on_area_3d_body_entered(body):
	body.global_transform.origin = Vector3(0,3,0)
