extends Area3D
class_name PowerUp3

# Cambia el nombre de la señal para coincidir con lo que busca el manager
signal powerup_collected(powerup_name: String, powerup_node: Node)

@export var powerup_name: String = "PowerUp3"

func _ready():
	body_entered.connect(_on_body_entered)
	add_to_group("PowerUp")  # Asegúrate de que está en el grupo
	print("💡 Power-up inicializado:", powerup_name)

func _on_body_entered(body: Node):
	if body.is_in_group("Player"):
		print("🎯 Jugador detectado en power-up:", powerup_name)
		powerup_collected.emit(powerup_name, self)
		set_deferred("monitoring", false)
