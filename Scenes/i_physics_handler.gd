extends Node
class_name IPhysicsHandler

# Métodos básicos (existían previamente)
func update(delta: float, transform_basis: Basis) -> void:
	push_error("Debe implementar el método update(delta, transform_basis)")

func get_velocity() -> Vector3:
	push_error("Debe implementar el método get_velocity()")
	return Vector3.ZERO

func set_engine_force(force: float) -> void:
	push_error("Debe implementar el método set_engine_force(force)")

func set_mass(mass: float) -> void:
	push_error("Debe implementar el método set_mass(mass)")

func set_drag_coefficient(drag: float) -> void:
	push_error("Debe implementar el método set_drag_coefficient(drag)")

func set_gravity(gravity: float) -> void:
	push_error("Debe implementar el método set_gravity(gravity)")

func set_is_on_floor_func(callback: Callable) -> void:
	push_error("Debe implementar el método set_is_on_floor_func(callback)")

# --- Nuevos métodos añadidos para manejo de pendientes y gravedad ---

# Establece la normal de la superficie actual (para pendientes)
func set_floor_normal(normal: Vector3) -> void:
	push_error("Debe implementar el método set_floor_normal(normal)")

# Configura la fuerza de ajuste para pendientes (0-1)
func set_slope_adjustment_strength(strength: float) -> void:
	push_error("Debe implementar el método set_slope_adjustment_strength(strength)")

# Establece el ángulo máximo para aplicar gravedad extra (en grados)
func set_max_slope_angle(angle: float) -> void:
	push_error("Debe implementar el método set_max_slope_angle(angle)")

# Configura la gravedad extra aplicable en pendientes
func set_max_slope_gravity_boost(boost: float) -> void:
	push_error("Debe implementar el método set_max_slope_gravity_boost(boost)")

# Habilita/deshabilita el ajuste automático de pendientes
func set_slope_adjustment_enabled(enabled: bool) -> void:
	push_error("Debe implementar el método set_slope_adjustment_enabled(enabled)")

# Obtiene información sobre el estado actual de superficie
func get_surface_info() -> Dictionary:
	push_error("Debe implementar el método get_surface_info()")
	return {
		"on_slope": false,
		"slope_angle": 0.0,
		"applied_adjustment": 0.0
	}
