extends IPowerUpManager

@export var powerup_label: Label
var powerup_stack: Array[String] = []

func _ready():
	if not powerup_label:
		push_warning("No se asignó powerup_label, la UI no se actualizará")
	
	_connect_existing_powerups()

func _connect_existing_powerups():
	var nodes = get_tree().get_nodes_in_group("PowerUp")
	if nodes.is_empty():
		print("⚠️ No se encontraron nodos en el grupo 'PowerUp'")
	for node in nodes:
		if node.has_signal("powerup_collected"):
			var connect_result = node.powerup_collected.connect(_on_powerup_collected, CONNECT_DEFERRED | CONNECT_PERSIST)
			if connect_result == OK:
				print("✅ Conexión establecida con:", node.name)
			else:
				push_error("❌ Falló conexión con: %s. Error: %s" % [node.name, connect_result])
		else:
			print("⚠️ Nodo %s no tiene la señal 'powerup_collected'" % node.name)
func _on_powerup_collected(powerup_name: String, powerup_node: Node):
	print("🧲 Señal recibida en _on_powerup_collected con:", powerup_name)
	register_powerup(powerup_name, powerup_node)

func register_powerup(tipo: String, powerup_node: Node) -> void:
	print("🎁 Intentando registrar power-up:", tipo)
	if not tipo in ["PowerUp1", "PowerUp2", "PowerUp3", "PowerUp4"]:
		push_error("❌ Tipo de power-up desconocido:", tipo)
		return
	
	powerup_stack.append(tipo)
	_actualizar_powerup_label()
	
	if is_instance_valid(powerup_node):
		powerup_node.queue_free()
	
	print("✅ Power-up agregado al stack. Total:", powerup_stack.size())

func activar_powerup() -> void:
	if powerup_stack.is_empty():
		print("⚠️ No hay power-ups para activar.")
		return
	
	var usado = powerup_stack.pop_back()
	_actualizar_powerup_label()
	print("🚀 Activando power-up:", usado)
	# Aquí debes emitir la señal correspondiente (ejemplo):
	if has_signal("powerup_speed_boost"):
		emit_signal("powerup_speed_boost", 5.0)
	else:
		print("⚠️ Señal 'powerup_speed_boost' no definida o no conectada")

func _actualizar_powerup_label() -> void:
	if not is_instance_valid(powerup_label):
		print("⚠️ Powerup Label no válido.")
		return
	
	powerup_label.text = "Power-ups: " + ("ninguno" if powerup_stack.is_empty() else ", ".join(powerup_stack))
	print("📊 UI actualizada. Power-ups:", powerup_stack)
