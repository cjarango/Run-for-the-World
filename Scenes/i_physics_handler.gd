extends Node
class_name IPhysicsHandler

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
