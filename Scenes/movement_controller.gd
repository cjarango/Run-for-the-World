extends IMovementController
class_name MovementController

@export var acceleration_rate: float = 10.0
@export var deceleration_rate: float = 15.0

var base_force: float = 0.0
var base_speed: float = 1.0
var current_multiplier: float = 1.0
var input_axis: float = 0.0
var current_force: float = 0.0

var enabled := true  # 👈 Esto es importante

func set_enable(value: bool) -> void:
	enabled = value

func set_base_parameters(base_force_param: float) -> void:
	base_force = base_force_param
	reset_force_multiplier()

func apply_force_multiplier(multiplier: float) -> void:
	current_multiplier = multiplier

func reset_force_multiplier() -> void:
	current_multiplier = 1.0

func set_input_axis(value: float) -> void:
	input_axis = clamp(value, -1.0, 1.0)

func update_movement(delta: float) -> void:
	if not enabled:
		current_force = 0.0
		return
	var target_force = input_axis * base_force * current_multiplier
	var rate = acceleration_rate if abs(input_axis) > 0.1 else deceleration_rate
	
	current_force = lerp(current_force, target_force, rate * delta)

func get_current_engine_force() -> float:
	return current_force
