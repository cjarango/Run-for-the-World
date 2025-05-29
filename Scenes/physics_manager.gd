extends IPhysicsHandler

@export var mass := 60.0
@export var drag_coefficient := 0.002
@export var gravity := 9.81
@export var ground_friction := 0.7  # Fricción cuando está en el suelo

var velocity: Vector3 = Vector3.ZERO
var engine_force: float = 0.0
var input_direction: float = 0.0
var is_on_floor_func: Callable = func() -> bool: return false

# --- Implementación de la interfaz ---
func set_mass(new_mass: float) -> void:
	mass = new_mass

func set_drag_coefficient(new_drag: float) -> void:
	drag_coefficient = new_drag

func set_gravity(new_gravity: float) -> void:
	gravity = new_gravity

func set_is_on_floor_func(callback: Callable) -> void:
	is_on_floor_func = callback

func set_engine_force(force: float) -> void:
	engine_force = force

func get_velocity() -> Vector3:
	return velocity

func update(delta: float, transform_basis: Basis) -> void:
	_apply_gravity(delta)
	_apply_engine_force(delta, transform_basis)
	_apply_resistive_forces(delta)
	
	# Reset Y velocity if on floor (optional)
	if is_on_floor_func.call() and velocity.y < 0:
		velocity.y = 0

# --- Métodos internos ---
func _apply_gravity(delta: float) -> void:
	if not is_on_floor_func.call():
		velocity.y -= gravity * delta

func _apply_engine_force(delta: float, basis: Basis) -> void:
	velocity += basis.z * (engine_force / mass) * delta

func _apply_resistive_forces(delta: float) -> void:
	var horizontal_velocity = Vector3(velocity.x, 0.0, velocity.z)
	var speed = horizontal_velocity.length()
	
	if speed > 0.0:
		var drag_force = -horizontal_velocity.normalized() * speed * speed * drag_coefficient
		velocity += drag_force * delta

	# Fricción en el suelo
	if is_on_floor_func.call():
		velocity.x *= ground_friction
		velocity.z *= ground_friction
		if abs(velocity.x) < 0.1: velocity.x = 0.0
		if abs(velocity.z) < 0.1: velocity.z = 0.0
