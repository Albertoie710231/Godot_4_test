extends SpringArm3D

var camera_h = 0.0
var camera_v = 0.0

@export var mouse_sensitivity := 0.005
@export var controller_sesitivity = 2

#@onready var _spring_arm = $PrincipalSpringArm

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if get_node("PrincipalCamera").current == true:
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			camera_h -= event.relative.x * mouse_sensitivity
			camera_h = wrapf(camera_h, deg_to_rad(0), deg_to_rad(360))
			rotation.y = camera_h
			camera_v -= event.relative.y * mouse_sensitivity
			camera_v = clamp(camera_v, deg_to_rad(-60), deg_to_rad(30))
			rotation.x = camera_v

func _process(delta):
	var input_dir = Input.get_vector("rotate_camera_left", "rotate_camera_right", "rotate_camera_up", "rotate_camera_down").normalized()
	if input_dir:
		camera_h -= input_dir.x * delta * controller_sesitivity
		camera_h = wrapf(camera_h, deg_to_rad(0), deg_to_rad(360))
		rotation.y = camera_h
		camera_v -= input_dir.y * delta * controller_sesitivity
		camera_v = clamp(camera_v, deg_to_rad(-60), deg_to_rad(30))
		rotation.x = camera_v
