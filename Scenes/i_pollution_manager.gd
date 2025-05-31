extends Node
class_name IPollutionManager

## Debe ser implementado para registrar un emisor de contaminación.
## @param emitter: Nodo que emitirá contaminación (ej: un vehículo).
func register_emitter(emitter: Node) -> void:
	push_error("Método abstracto: register_emitter(emitter) debe ser implementado")

## Añade una cantidad de contaminación al sistema.
## @param amount: Valor positivo que incrementa la contaminación.
func add_pollution(amount: float) -> void:
	push_error("Método abstracto: add_pollution(amount) debe ser implementado")
	
	
func get_pollution() -> float:
	push_error("Método abstracto: get_pollution() debe ser implementado")
	return 0.0

## Señal emitida cuando el nivel de contaminación cambia.
signal pollution_changed(pollution_value: float)
