extends CharacterBody3D

@export var max_speed := 100.0
@export var acceleration := 200.0
@export var deceleration := 300.0
@export var mouse_sensitivity := 0.003

var yaw := 0.0
var current_speed := 0.0
var target_speed := 0.0

@onready var camera = $Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		rotation.y = yaw  # Gira el coche

	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	# Define velocidad objetivo según entrada del jugador
	if Input.is_action_pressed("move_forward"):
		target_speed = max_speed
	elif Input.is_action_pressed("move_backward"):
		target_speed = -max_speed
	else:
		target_speed = 0.0  # Si no se pulsa nada, se frena

	# Interpolación hacia la velocidad deseada
	if current_speed < target_speed:
		current_speed += acceleration * delta
		current_speed = min(current_speed, target_speed)
	elif current_speed > target_speed:
		current_speed -= deceleration * delta
		current_speed = max(current_speed, target_speed)

	# Movimiento hacia adelante o atrás
	var direction = transform.basis.z * current_speed
	velocity = direction
	move_and_slide()
