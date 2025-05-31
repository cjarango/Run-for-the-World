extends CharacterBody3D

## Dependencias inyectadas
@export var physics_handler: IPhysicsHandler
@export var pollution_manager: IPollutionManager
@export var powerup_manager: IPowerUpManager
@export var input_handler: IInputHandler
@export var camera_controller: ICameraController
@export var movement_controller: IMovementController
@export var powerup_controller: IPowerUpController

## Configuración del vehículo
@export var max_engine_force := 40000.0
@export var mass := 150.0  # Aumentado para mejor física
@export var drag_coefficient := 0.002
@export var rolling_resistance := 0.1
@export var gravity := 30.0  # Aumentado para mejor adherencia

## Componentes del nodo
@onready var acceleration_sound = $AccelerationSound
@onready var speedometer_label: Label = get_node("/root/Main/CanvasLayer/Label")
@onready var ray_cast = $GroundRayCast # Asegúrate de tener un RayCast3D apuntando hacia abajo

## Configuración de controles
@export var mouse_sensitivity := 0.003
@export var joystick_sensitivity := 3.0

## Variables de estado
var yaw := 0.0
var current_engine_force := 0.0
var current_floor_normal: Vector3 = Vector3.UP

signal movement_with_pollution(boost_active: bool)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	yaw = rotation.y
	
	if movement_controller:
		movement_controller.set_base_parameters(max_engine_force)
	
	if powerup_controller:
		powerup_controller.initialize(max_engine_force)
		powerup_controller.boost_started.connect(_on_boost_started)
		powerup_controller.boost_ended.connect(_on_boost_ended)
	
	_initialize_dependencies()
	camera_controller.set_enable(true)

func _initialize_dependencies():
	if pollution_manager:
		pollution_manager.register_emitter(self)
	
	if physics_handler:
		_configure_physics_handler()
	else:
		push_error("Falta physics_handler - El personaje no funcionará correctamente")
	
	if powerup_manager:
		powerup_manager.powerup_speed_boost.connect(_on_powerup_speed_boost)

func _configure_physics_handler():
	physics_handler.set_mass(mass)
	physics_handler.set_drag_coefficient(drag_coefficient)
	physics_handler.set_gravity(gravity)
	physics_handler.set_is_on_floor_func(_is_on_floor)
	physics_handler.set_slope_adjustment_enabled(true)
	physics_handler.set_max_slope_angle(45.0)  # Ángulo máximo de pendiente
	physics_handler.set_max_slope_gravity_boost(50.0)  # Gravedad extra en pendientes
	physics_handler.set_slope_adjustment_strength(0.8)  # Fuerza de ajuste

func _is_on_floor() -> bool:
	return is_on_floor() or ray_cast.is_colliding()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		rotation.y = yaw
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	if input_handler and camera_controller.get_enable() == true:
		yaw -= input_handler.get_yaw_delta(delta)
		rotation.y = yaw

		if input_handler.is_boost_activation_requested() and powerup_manager:
			powerup_manager.activar_powerup()
	
	if camera_controller:
		if camera_controller.get_enable() == true:
			camera_controller.update_camera_position(self)

func _physics_process(delta):
	_update_floor_normal()  # Actualizar la normal del suelo cada frame
	_handle_movement(delta)
	_update_physics(delta)
	move_and_slide()
	update_speedometer()

func _update_floor_normal():
	# Obtener la normal del suelo actual
	if is_on_floor():
		current_floor_normal = get_floor_normal()
	elif ray_cast.is_colliding():
		current_floor_normal = ray_cast.get_collision_normal()
	else:
		current_floor_normal = Vector3.UP
	
	# Pasar la normal al physics handler
	if physics_handler:
		physics_handler.set_floor_normal(current_floor_normal)

func _handle_movement(delta):
	if input_handler and movement_controller:
		var input_dir = input_handler.get_input_axis("move_backward", "move_forward")
		
		movement_controller.set_input_axis(input_dir)
		movement_controller.update_movement(delta)
		current_engine_force = movement_controller.get_current_engine_force()
		
		if input_dir != 0.0:
			var is_boosted = powerup_controller.get_is_boost_active() if powerup_controller else false
			emit_signal("movement_with_pollution", is_boosted)

func _update_physics(delta):
	if physics_handler:
		physics_handler.set_engine_force(current_engine_force)
		physics_handler.update(delta, transform.basis)
		velocity = physics_handler.get_velocity()

func update_speedometer():
	if speedometer_label:
		var speed_kmh = Vector3(velocity.x, 0, velocity.z).length() * 3.6
		speedometer_label.text = "%.1f km/h" % speed_kmh

func _on_powerup_speed_boost(duration):
	if powerup_controller:
		powerup_controller.activate_speed_boost(duration, 2.0)

func _on_boost_started():
	print("🚀 Boost activado!")
	emit_signal("movement_with_pollution", true)

func _on_boost_ended():
	print("⏱️ Boost terminado")
	emit_signal("movement_with_pollution", false)
