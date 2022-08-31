extends Node3D

var in_range_flag : bool = false
var body_entered_flag : bool = false
var camera_offset_flag : bool = true
var timeout_flag : bool = false
var sweep_signal_flag : bool = false
var camera_offset : Vector3 = Vector3.ZERO
var trash_list : Array = []

signal shoot_trash()
signal sweep_signal()

@onready var _ray_cast = $RayCast3D
@onready var _area_collision = $Area3D/CollisionShape3D
@onready var _camera : SpringArm3D = $"../PrincipalSpringArm"
@onready var _remote_tranform_camera : RemoteTransform3D = $"../Player/PivotRemoteTransform/RemoteTransform3D"
@onready var _pivot_remote_camera : Node3D = $"../Player/PivotRemoteTransform"
#@onready var _pivot : Node3D = $".."
@onready var _spawn_trash : Node3D = $SpawnTrash
@onready var _timer : Timer = $Timer

func _physics_process(_delta) -> void:
	if Input.is_action_pressed("click"):
		if camera_offset_flag:
			camera_offset.x = _camera.rotation.x
			camera_offset_flag = false
			sweep_signal_flag = true
		_remote_tranform_camera.rotation.x = _camera.rotation.x - camera_offset.x
		_remote_tranform_camera.rotation.x = clamp(_remote_tranform_camera.rotation.x, deg_to_rad(-20), deg_to_rad(60))
		if _timer.is_stopped() and timeout_flag == false:
			_timer.start(0.5)
		
		if _timer.get_time_left() == 0.0:
			if sweep_signal_flag:
				sweep_signal.emit()
				sweep_signal_flag = false
			_pivot_remote_camera.rotation.y = _camera.rotation.y
			_pivot_remote_camera.rotation.y = wrapf(_pivot_remote_camera.rotation.y, deg_to_rad(0), deg_to_rad(360))
			if _ray_cast.is_colliding():
				sweep()
	
	elif Input.is_action_just_released("click"):
		if _timer.get_time_left() != 0.0:
			shoot()
		if sweep_signal_flag == false:
			sweep_signal.emit()
		_area_collision.disabled = true
		_remote_tranform_camera.rotation.x = 0.0
		_remote_tranform_camera.rotation.y = 0.0
		timeout_flag = false
		camera_offset_flag = true
		_timer.stop()

func sweep() -> void:
	_area_collision.disabled = false
	if _ray_cast.get_collider():
		if _ray_cast.get_collider().is_in_group("bodies"):
			_ray_cast.get_collider().apply_central_force(_ray_cast.get_collision_normal() * 100)
			if body_entered_flag == true:
				_ray_cast.get_collider().set_linear_velocity(Vector3.ZERO)
				_ray_cast.get_collider().set_angular_velocity(Vector3.ZERO)
				_ray_cast.get_collider().set_lock_rotation_enabled(true)
				var scene = PackedScene.new()
				scene.pack(_ray_cast.get_collider())
				trash_list.append(scene)
				_ray_cast.get_collider().queue_free()
				body_entered_flag = false

func shoot() -> void:
	if trash_list:
		var t = trash_list.back().instantiate()
		t.set_lock_rotation_enabled(false)
		t.transform.basis = _spawn_trash.transform.basis
		_spawn_trash.add_child(t)
		shoot_trash.connect(_spawn_trash.get_child(_spawn_trash.get_child_count()-1).shoot_trash)
		shoot_trash.emit()
		shoot_trash.disconnect(_spawn_trash.get_child(_spawn_trash.get_child_count()-1).shoot_trash)
		trash_list.pop_back()

func _on_area_3d_body_entered(_body):
	body_entered_flag = true


func _on_timer_timeout():
	timeout_flag = true
	_timer.stop()
