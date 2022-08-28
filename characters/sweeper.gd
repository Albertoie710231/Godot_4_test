extends Node3D

var in_range_flag : bool = false
var body_entered_flag : bool = false
var camera_offset_flag : bool = true
var timeout_flag : bool = false
var camera_offset : Vector3 = Vector3.ZERO
var trash_list : Array = []

signal shoot_trash()
signal sweep_signal()

@onready var _ray_cast = $RayCast3D
@onready var _area_collision = $Area3D/CollisionShape3D
@onready var _camera : SpringArm3D = $"../PrincipalSpringArm"
@onready var _remote_tranform_camera : RemoteTransform3D = $"../Player/PivotRemoteTransform/RemoteTransform3D"
@onready var _pivot_remote_camera : Node3D = $"../Player/PivotRemoteTransform"
@onready var _pivot : Node3D = $".."
@onready var _spawn_trash : Node3D = $SpawnTrash
@onready var _timer : Timer = $Timer

func _unhandled_input(event:InputEvent) -> void:
	if Input.is_action_pressed("click"):
		if camera_offset_flag:
			sweep_signal.emit()
			camera_offset.x = _camera.rotation.x
			camera_offset_flag = false
		_remote_tranform_camera.rotation.x = _camera.rotation.x - camera_offset.x
		_remote_tranform_camera.rotation.x = clamp(_remote_tranform_camera.rotation.x, deg2rad(-20), deg2rad(60))
		_pivot_remote_camera.rotation.y = _camera.rotation.y - camera_offset.y
		if _timer.is_stopped() and timeout_flag == false:
			_timer.start(0.5)
		
		if _ray_cast.is_colliding() and _timer.get_time_left() == 0.0:
			sweep()
	
	elif Input.is_action_just_released("click"):
		if _timer.get_time_left() != 0.0:
			shoot()
		sweep_signal.emit()
		_area_collision.disabled = true
		_remote_tranform_camera.rotation.x = 0.0
		_remote_tranform_camera.rotation.y = 0.0
		timeout_flag = false
		camera_offset_flag = true
		#print(_timer.get_time_left())
		_timer.stop()

func sweep() -> void:
	_area_collision.disabled = false
	if _ray_cast.get_collider():
		if _ray_cast.get_collider().is_in_group("bodies"):
			_ray_cast.get_collider().apply_central_impulse(_ray_cast.get_collision_normal())
			if body_entered_flag == true:
				var scene = PackedScene.new()
				scene.pack(_ray_cast.get_collider())
				trash_list.append(scene)
				_ray_cast.get_collider().queue_free()
				body_entered_flag = false

func shoot() -> void:
	if trash_list:
		var t = trash_list.back().instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		_spawn_trash.add_child(t)
		#print(_spawn_trash.get_child(_spawn_trash.get_child_count()-1).shoot_trash)
		shoot_trash.connect(_spawn_trash.get_child(_spawn_trash.get_child_count()-1).shoot_trash)
		shoot_trash.emit()
		shoot_trash.disconnect(_spawn_trash.get_child(_spawn_trash.get_child_count()-1).shoot_trash)
		#var impulse = _spawn_trash.get_child(_spawn_trash.get_child_count()-1).transform.basis.z
		#print(impulse)
		#_spawn_trash.get_child(_spawn_trash.get_child_count()-1).apply_central_impulse(-impulse * 1000)
		trash_list.pop_back()
		#print(trash_list)

func _on_area_3d_body_entered(body):
	body_entered_flag = true


func _on_timer_timeout():
	timeout_flag = true
	_timer.stop()
