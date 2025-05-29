extends IPollutionManager

@export var max_pollution: float = 100.0              ## Límite máximo de contaminación.
@export var pollution_decay_rate: float = 0.005       ## Reducción por segundo.
@export var base_pollution_increase: float = 0.02     ## Contaminación base por emisión.
@export var boost_pollution_increase: float = 0.04    ## Extra si hay "boost".

var _current_pollution: float = 0.0
var _emitters: Array[Node] = []

# -----------------------------------------------------------------------------
## Registra un emisor y conecta su señal de contaminación.
func register_emitter(emitter: Node) -> void:
	if not _emitters.has(emitter):
		_emitters.append(emitter)
		emitter.connect("movement_with_pollution", _on_emitter_pollution)

## Añade contaminación (con clamp para evitar exceder el máximo).
func add_pollution(amount: float) -> void:
	var previous_pollution = _current_pollution
	_current_pollution = clamp(_current_pollution + amount, 0.0, max_pollution)
	if not is_equal_approx(previous_pollution, _current_pollution):
		pollution_changed.emit(_current_pollution)

# -----------------------------------------------------------------------------
## Reduce la contaminación gradualmente (llamado en _process).
func decay_pollution(delta: float) -> void:
	var previous_pollution = _current_pollution
	_current_pollution = max(_current_pollution - pollution_decay_rate * delta, 0.0)
	if not is_equal_approx(previous_pollution, _current_pollution):
		pollution_changed.emit(_current_pollution)

## Callback cuando un emisor genera contaminación.
func _on_emitter_pollution(boost_active: bool) -> void:
	var amount = base_pollution_increase
	if boost_active:
		amount += boost_pollution_increase
	add_pollution(amount)

func _process(delta: float) -> void:
	decay_pollution(delta)
