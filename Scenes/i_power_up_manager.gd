extends Node
class_name IPowerUpManager

## Registra un nuevo power-up en el inventario
## @param tipo: Identificador del tipo de power-up
## @param powerup_node: Nodo del power-up que se recogió (para eliminarlo)
func register_powerup(tipo: String, powerup_node: Node) -> void:
	push_error("Método abstracto: register_powerup() debe ser implementado")

## Activa el power-up más reciente del inventario
func activar_powerup() -> void:
	push_error("Método abstracto: activar_powerup() debe ser implementado")

## Señal emitida cuando se activa un power-up de velocidad
signal powerup_speed_boost(duration: float)
