extends Area3D

# Referencias a UI
@onready var Labcounter_label = get_node("/root/Main/CanvasLayer/Label2")
@onready var Timer_label = get_node("/root/Main/CanvasLayer/Timer")

# Control de carrera
var vueltas_completadas := 0
var max_vueltas := 3
var checkpoint_index := 0
var carrera_en_curso := false
var tiempo_inicio := 0.0
var tiempo_final := 0.0
var cronometro_iniciado := false

# Lista de checkpoints fijos (circular)
var checkpoints := []

func _ready():
	# Crear lista circular de checkpoints (orden fijo)
	checkpoints = [
		get_node("/root/Main/Checkpoint1"),
		get_node("/root/Main/Checkpoint2"),
		get_node("/root/Main/Checkpoint3"),
		self  # La meta
	]

	# Conectar todos los checkpoints a función común
	for checkpoint in checkpoints:
		checkpoint.connect("body_entered", _on_checkpoint_entered.bind(checkpoint))

	# Primer checkpoint objetivo: Checkpoint1
	checkpoint_index = 0  

func _process(delta):
	if carrera_en_curso:
		actualizar_cronometro()

func _on_checkpoint_entered(body, checkpoint):
	if body.name == "CuboPrueba" and body.is_in_group("Player"):
		if not cronometro_iniciado and checkpoint == self:
			# Primera vez tocando la meta: inicia la carrera
			cronometro_iniciado = true
			iniciar_cronometro()
			print("🏁 Carrera iniciada")

		# Validar orden correcto
		if checkpoint == checkpoints[checkpoint_index]:
			# Avanzar al siguiente checkpoint circularmente
			checkpoint_index = (checkpoint_index + 1) % checkpoints.size()

			if checkpoint == self and cronometro_iniciado:
				# La meta fue alcanzada en orden -> vuelta válida
				vueltas_completadas += 1
				actualizar_contador()

				if vueltas_completadas >= max_vueltas:
					finalizar_carrera()
				else:
					print("✅ Vuelta completada: %d/%d" % [vueltas_completadas, max_vueltas])
			elif checkpoint != self:
				print("Checkpoint correcto ➡️")
		else:
			print("❌ Checkpoint fuera de orden o intento de trampa")

func iniciar_cronometro():
	tiempo_inicio = Time.get_ticks_msec()
	carrera_en_curso = true
	vueltas_completadas = 0
	actualizar_contador()
	Timer_label.text = "Tiempo: 0.00s"

func actualizar_cronometro():
	var tiempo_actual = (Time.get_ticks_msec() - tiempo_inicio) / 1000.0
	Timer_label.text = "Tiempo: %.2fs" % tiempo_actual

func finalizar_carrera():
	tiempo_final = (Time.get_ticks_msec() - tiempo_inicio) / 1000.0
	carrera_en_curso = false
	Timer_label.text = "Final: %.2fs" % tiempo_final
	print("🏁 ¡Carrera completada en %.2fs!" % tiempo_final)

	# Guardar tiempo
	Global.best_time = tiempo_final
	Global.save_best_times(Global.player_name, tiempo_final)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func actualizar_contador():
	Labcounter_label.text = "Vueltas: %d/%d" % [vueltas_completadas, max_vueltas]
