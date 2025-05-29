extends Node
class_name IPowerUpController

# Indica si hay un boost activo
func get_is_boost_active() -> bool:
	return false

# Activa un power-up de velocidad
func activate_speed_boost(duration: float, force_multiplier: float) -> void:
	pass
