extends Node
class_name IMovementController

# Configura los parámetros base del movimiento
func set_base_parameters(base_force: float) -> void:
	pass
	
func set_enable(value: bool) -> void:
	pass

func set_input_axis(value: float) -> void:
	pass

# Actualiza el cálculo de movimiento
func update_movement(delta: float) -> void:
	pass

# Obtiene la fuerza actual del motor
func get_current_engine_force() -> float:
	return 0.0

# Aplica un multiplicador de fuerza temporal
func apply_force_multiplier(multiplier: float) -> void:
	pass

# Restablece la fuerza a su valor normal
func reset_force_multiplier() -> void:
	pass
