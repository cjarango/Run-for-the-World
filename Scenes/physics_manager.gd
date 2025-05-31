extends IPhysicsHandler

@export_category("Basic Parameters")
@export var mass := 150.0
@export var drag_coefficient := 0.002
@export var base_gravity := 30.0
@export var ground_friction := 0.9

@export_category("Slope Handling")
@export var slope_adjustment_strength := 0.8
@export var max_slope_angle := 45.0 # grados
@export var max_slope_gravity_boost := 60.0
@export var min_slope_adhesion := 10.0 # gravedad mínima aplicada incluso en suelo

@export_category("Advanced")
@export var slope_adjustment_enabled := true
@export var debug_mode := false
@export var preserve_speed_on_slopes := true

var velocity: Vector3 = Vector3.ZERO
var engine_force: float = 0.0
var is_on_floor_func: Callable = func() -> bool: return false
var current_floor_normal: Vector3 = Vector3.UP
var current_slope_angle: float = 0.0
var applied_adjustment: float = 0.0

# --- Implementación de la interfaz ---
func set_mass(new_mass: float) -> void:
	mass = new_mass

func set_drag_coefficient(new_drag: float) -> void:
	drag_coefficient = new_drag

func set_gravity(new_gravity: float) -> void:
	base_gravity = new_gravity

func set_is_on_floor_func(callback: Callable) -> void:
	is_on_floor_func = callback

func set_engine_force(force: float) -> void:
	engine_force = force

func set_floor_normal(normal: Vector3) -> void:
	current_floor_normal = normal.normalized() if normal != Vector3.ZERO else Vector3.UP

func set_slope_adjustment_strength(strength: float) -> void:
	slope_adjustment_strength = clamp(strength, 0.0, 1.0)

func set_max_slope_angle(angle: float) -> void:
	max_slope_angle = clamp(angle, 0.0, 89.0)

func set_max_slope_gravity_boost(boost: float) -> void:
	max_slope_gravity_boost = max(boost, 0.0)

func set_slope_adjustment_enabled(enabled: bool) -> void:
	slope_adjustment_enabled = enabled

func get_velocity() -> Vector3:
	return velocity

func get_surface_info() -> Dictionary:
	return {
		"on_slope": current_slope_angle > 5.0,
		"slope_angle": current_slope_angle,
		"applied_adjustment": applied_adjustment,
		"effective_gravity": _calculate_effective_gravity()
	}

func update(delta: float, transform_basis: Basis) -> void:
	_calculate_slope_angle()
	_apply_gravity(delta)
	_apply_engine_force(delta, transform_basis)
	
	if preserve_speed_on_slopes:
		_apply_resistive_forces_preserving_speed(delta)
	else:
		_apply_resistive_forces(delta)
	
	if slope_adjustment_enabled:
		_apply_slope_adjustment(delta)
	
	if is_on_floor_func.call() and velocity.y < 0:
		velocity.y = max(velocity.y, -1.0)

	if debug_mode:
		_print_debug_info()

# --- Métodos internos ---
func _calculate_slope_angle() -> void:
	current_slope_angle = rad_to_deg(acos(current_floor_normal.dot(Vector3.UP)))

func _calculate_effective_gravity() -> float:
	var effective_gravity = base_gravity
	
	if is_on_floor_func.call():
		var slope_factor = clamp(current_slope_angle / max_slope_angle, 0.0, 1.0)
		if slope_factor > 0.7:
			effective_gravity += slope_factor * max_slope_gravity_boost
		effective_gravity = max(effective_gravity, min_slope_adhesion)
	
	return effective_gravity

func _apply_gravity(delta: float) -> void:
	var effective_gravity = _calculate_effective_gravity()
	
	if not is_on_floor_func.call():
		velocity.y -= effective_gravity * delta
	else:
		velocity.y -= min_slope_adhesion * delta

func _apply_engine_force(delta: float, basis: Basis) -> void:
	velocity += basis.z * (engine_force / mass) * delta

func _apply_resistive_forces(delta: float) -> void:
	var horizontal_velocity = Vector3(velocity.x, 0.0, velocity.z)
	var speed = horizontal_velocity.length()
	
	if speed > 0.0:
		var drag_force = -horizontal_velocity.normalized() * speed * speed * drag_coefficient
		velocity += drag_force * delta

	if is_on_floor_func.call():
		var friction_factor = ground_friction * (1.0 - (current_slope_angle / max_slope_angle * 0.5))
		velocity.x *= friction_factor
		velocity.z *= friction_factor
		if abs(velocity.x) < 0.1: velocity.x = 0.0
		if abs(velocity.z) < 0.1: velocity.z = 0.0

func _apply_resistive_forces_preserving_speed(delta: float) -> void:
	var horizontal_velocity = Vector3(velocity.x, 0.0, velocity.z)
	var speed = horizontal_velocity.length()
	
	if speed > 0.0:
		var drag_force = -horizontal_velocity.normalized() * speed * speed * drag_coefficient
		velocity += drag_force * delta
	
	if is_on_floor_func.call():
		var speed_reduction = 1.0 - (0.3 * clamp(current_slope_angle / max_slope_angle, 0.0, 1.0))
		velocity.x *= lerp(ground_friction, 1.0, speed_reduction)
		velocity.z *= lerp(ground_friction, 1.0, speed_reduction)

func _apply_slope_adjustment(delta: float) -> void:
	if is_on_floor_func.call() and current_slope_angle > 5.0:
		var slope_factor = clamp(current_slope_angle / max_slope_angle, 0.0, 1.0)
		applied_adjustment = slope_adjustment_strength * slope_factor
		
		var vertical_adjustment = -current_floor_normal * applied_adjustment * delta * mass
		vertical_adjustment.x = 0
		vertical_adjustment.z = 0
		velocity += vertical_adjustment

func _print_debug_info() -> void:
	var info = get_surface_info()
	print("--- Physics Debug ---")
	print("Slope Angle: %.1f°" % info.slope_angle)
	print("Effective Gravity: %.1f" % info.effective_gravity)
	print("Adjustment Strength: %.2f" % info.applied_adjustment)
	print("Velocity: %s (%.1f)" % [velocity, velocity.length()])
	print("-------------------")
