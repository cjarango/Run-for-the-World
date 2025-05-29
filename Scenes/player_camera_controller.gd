extends ICameraController
class_name PlayerCameraController

@export var camera_path: NodePath
@export var offset_distance := 20.0
@export var keep_height := true

var camera: Camera3D

func _ready():
	if camera_path:
		camera = get_node(camera_path)
	else:
		push_error("No se asignó camera_path en PlayerCameraController")

func update_camera_position(player: Node3D) -> void:
	if camera == null:
		return
	
	var character_pos = player.global_transform.origin
	character_pos.y = 0

	var cam_y = camera.global_transform.origin.y
	var cam_offset = camera.transform.origin

	var new_cam_pos = character_pos + cam_offset + -player.transform.basis.z * offset_distance
	if keep_height:
		new_cam_pos.y = cam_y
	
	camera.global_transform.origin = new_cam_pos
