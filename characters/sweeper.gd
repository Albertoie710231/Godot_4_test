extends Node3D

#@onready var _pivot = $"../Pivot"

var in_range_flag : bool = false
var body_entered_flag : bool = false
var timeout_flag : bool = false
var trash_list : Array = []

@onready var _ray_cast = $RayCast3D
@onready var _area_collision = $Area3D/CollisionShape3D
@onready @export var _camera : SpringArm3D = $"../../../PrincipalSpringArm"
@onready @export var _pivot : Node3D = $".."
@onready var _spawn_trash : Node3D = $SpawnTrash
@onready var _timer : Timer = $Timer

func _unhandled_input(event:InputEvent) -> void:
	if Input.is_action_pressed("click"):
		rotation.x = _camera.rotation.x
		rotation.x = clamp(rotation.x, deg2rad(-20), deg2rad(60))
		if _timer.is_stopped() and timeout_flag == false:
			_timer.start(0.5)
		
		if _ray_cast.is_colliding() and _timer.get_time_left() == 0.0:
			sweep()
	
	elif Input.is_action_just_released("click"):
		if _timer.get_time_left() != 0.0:
			shoot()
		
		_area_collision.disabled = true
		rotation.x = 0.0
		timeout_flag = false
		
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
		_spawn_trash.get_child(_spawn_trash.get_child_count()-1).apply_central_impulse(Vector3(0,0,-20))
		trash_list.pop_back()
		print(trash_list)

func _on_area_3d_body_entered(body):
	body_entered_flag = true


func _on_timer_timeout():
	timeout_flag = true
	_timer.stop()
