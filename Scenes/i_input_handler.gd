extends Node

class_name IInputHandler

func get_yaw_delta(delta: float) -> float:
	return 0.0

func is_boost_activation_requested() -> bool:
	return false

func get_input_axis(forward_action: String, backward_action: String) -> float:
	return 0.0
