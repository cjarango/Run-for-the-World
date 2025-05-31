extends IPowerUpController
class_name PowerUpController

signal boost_started()
signal boost_ended()

@export var movement_controller: IMovementController
var original_force: float = 0.0
var is_boost_active: bool = false
var boost_timer: float = 0.0
var current_multiplier: float = 1.0

func initialize(base_force: float):
	original_force = base_force
	if movement_controller:
		movement_controller.set_base_parameters(base_force)

func _process(delta):
	if boost_timer > 0:
		boost_timer -= delta
		if boost_timer <= 0:
			_end_boost()

func get_is_boost_active() -> bool:
	return is_boost_active

func activate_speed_boost(duration: float, force_multiplier: float = 5.0):
	if is_boost_active:
		return
	
	is_boost_active = true
	boost_timer = duration
	current_multiplier = force_multiplier
	
	if movement_controller:
		movement_controller.apply_force_multiplier(force_multiplier)
	
	emit_signal("boost_started")

func _end_boost():
	is_boost_active = false
	if movement_controller:
		movement_controller.reset_force_multiplier()
	emit_signal("boost_ended")
