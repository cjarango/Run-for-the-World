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
@export var max_engine_force := 400000.0
@export var mass := 60.0
@export var drag_coefficient := 0.002
@export var rolling_resistance := 0.1
@export var gravity := 20

## Componentes del nodo
@onready var acceleration_sound = $AccelerationSound
@onready var speedometer_label: Label = get_node("/root/Main/CanvasLayer/Label")

## Configuración de controles
@export var mouse_sensitivity := 0.003
@export var joystick_sensitivity := 3.0

## Variables de estado
var yaw := 0.0
var current_engine_force := 0.0

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

func _is_on_floor() -> bool:
	return is_on_floor()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		rotation.y = yaw
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	if input_handler:
		yaw -= input_handler.get_yaw_delta(delta)
		rotation.y = yaw

		if input_handler.is_boost_activation_requested() and powerup_manager:
			powerup_manager.activar_powerup()
	
	if camera_controller:
		camera_controller.update_camera_position(self)

func _physics_process(delta):
	_handle_movement(delta)
	_update_physics(delta)
	move_and_slide()
	update_speedometer()

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
