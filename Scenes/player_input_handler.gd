extends IInputHandler
class_name PlayerInputHandler

@export var mouse_sensitivity := 0.003
@export var joystick_sensitivity := 3.0
@export var joystick_id := 0
const JOY_AXIS_LEFT_X := 0

var accumulated_yaw_delta := 0.0
var boost_requested := false

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# ← Mover a la derecha aumenta yaw (gira a la derecha)
		accumulated_yaw_delta += event.relative.x * mouse_sensitivity

	if event.is_action_pressed("powerActivate"):
		boost_requested = true

func get_yaw_delta(delta: float) -> float:
	var joy_x = Input.get_joy_axis(joystick_id, JOY_AXIS_LEFT_X)
	if abs(joy_x) > 0.1:
		# ← Invertido antes, ahora se suma
		accumulated_yaw_delta += joy_x * joystick_sensitivity * delta

	# Agregar movimiento horizontal por acciones del Input Map
	if Input.is_action_pressed("move_right"):
		accumulated_yaw_delta += joystick_sensitivity * delta
	if Input.is_action_pressed("move_left"):
		accumulated_yaw_delta -= joystick_sensitivity * delta

	var delta_to_return = accumulated_yaw_delta
	accumulated_yaw_delta = 0.0
	return delta_to_return

func is_boost_activation_requested() -> bool:
	var was_requested = boost_requested
	boost_requested = false
	return was_requested

func get_input_axis(forward_action: String, backward_action: String) -> float:
	return Input.get_axis(forward_action, backward_action)	
