extends CharacterBody3D

# 🔥 Parámetros del motor (optimizados para Godot)
@export var max_engine_force := 2000.0  # Fuerza ajustada para escala Godot
@export var mass := 60.0  # Masa más ligera para respuesta rápida
@export var drag_coefficient := 0.002  # Resistencia aerodinámica reducida
@export var rolling_resistance := 10.0  # Fricción ajustada

# 🎮 Control
@export var mouse_sensitivity := 0.003
@export var gravity := 30.0

@onready var speedometer_label = get_node("/root/Main/CanvasLayer/Label")

var yaw := 0.0
var current_engine_force := 0.0

@onready var camera = $Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		rotation.y = yaw
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	apply_gravity(delta)
	handle_engine(delta)
	apply_resistive_forces(delta)
	move_and_slide()
	update_speedometer()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

func handle_engine(delta):
	var input_dir = Input.get_axis("move_forward","move_backward")
	current_engine_force = lerp(
		current_engine_force,
		input_dir * max_engine_force,
		10.0 * delta  # Respuesta inmediata del motor
	)
	velocity += transform.basis.z * current_engine_force / mass * delta

func apply_resistive_forces(delta):
	var speed = velocity.length()
	if speed > 0:
		# Resistencia aerodinámica simplificada
		var drag_force = -velocity.normalized() * speed * speed * drag_coefficient
		velocity += drag_force * delta
	
	# Fricción en el suelo
	if is_on_floor():
		velocity.x *= 0.95
		velocity.z *= 0.95

func update_speedometer():
	if speedometer_label:
		var speed_kmh = Vector3(velocity.x, 0, velocity.z).length() * 3.6
		speedometer_label.text = "%.1f km/h" % speed_kmh
