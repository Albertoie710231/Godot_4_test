extends RigidDynamicBody3D

var shoot : bool = false

func shoot_trash() -> void:
	print("shoot")
	shoot = true
	

func _physics_process(delta):
	if shoot:
		shoot = false
