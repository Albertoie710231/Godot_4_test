extends Node3D

#@onready var _pivot = $"../Pivot"

@onready var _ray_cast = $RayCast3D
@onready var _area_collision = $Area3D/CollisionShape3D

func _physics_process(delta):
	if _ray_cast.is_colliding():
		print("Is in range")

func _unhandled_input(event):
	if Input.is_action_pressed("click"):
		sweep()
	elif Input.is_action_just_released("click"):
		_area_collision.disabled = true

func sweep() -> void:
	_area_collision.disabled = false

func _on_area_3d_body_entered(body):
	print("Entered")


func _on_area_3d_body_exited(body):
	print("Exited")
