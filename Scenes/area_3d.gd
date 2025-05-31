extends Area3D

# Referencias
@export var pollution_manager: IPollutionManager
@export var player_movement: IMovementController
@export var camara_movement: ICameraController
@export var  end_screen: CanvasLayer
@onready var Labcounter_label = get_node("/root/Main/CanvasLayer/Label2")
@onready var Timer_label = get_node("/root/Main/CanvasLayer/Timer")

# Control de carrera
var vueltas_completadas := 0
var max_vueltas := 1
var checkpoint_index := 0
var carrera_en_curso := false
var tiempo_inicio := 0.0
var tiempo_final := 0.0
var cronometro_iniciado := false

# Lista de checkpoints
var checkpoints := []

func _ready():
	# Configurar checkpoints
	checkpoints = [
		get_node("/root/Main/Checkpoint1"),
		get_node("/root/Main/Checkpoint2"),
		get_node("/root/Main/Checkpoint3"),
		self  # Meta
	]
	for checkpoint in checkpoints:
		checkpoint.connect("body_entered", _on_checkpoint_entered.bind(checkpoint))
	
	checkpoint_index = 0
	player_movement.set_enable(true)
	end_screen.visible = false 

func _process(delta):
	if carrera_en_curso:
		actualizar_cronometro()
	else:
		if Input.is_action_just_pressed("reset"):
			_reset_carrera()
		elif Input.is_action_just_pressed("goBackToMain"):
			_go_back_to_main_menu()

func _on_checkpoint_entered(body, checkpoint):
	if body.name == "CuboPrueba" and body.is_in_group("Player"):
		if not cronometro_iniciado and checkpoint == self:
			cronometro_iniciado = true
			iniciar_cronometro()
			print("🏁 Carrera iniciada")

		if checkpoint == checkpoints[checkpoint_index]:
			checkpoint_index = (checkpoint_index + 1) % checkpoints.size()

			if checkpoint == self and cronometro_iniciado:
				vueltas_completadas += 1
				actualizar_contador()

				if vueltas_completadas >= max_vueltas:
					finalizar_carrera()
				else:
					print("✅ Vuelta completada: %d/%d" % [vueltas_completadas, max_vueltas])
			elif checkpoint != self:
				print("Checkpoint correcto ➡️")
		else:
			print("❌ Checkpoint fuera de orden")

func iniciar_cronometro():
	tiempo_inicio = Time.get_ticks_msec()
	carrera_en_curso = true
	vueltas_completadas = 0
	actualizar_contador()
	Timer_label.text = "Tiempo: 0.00s"
	
	# Resetear contaminación al iniciar carrera
	if pollution_manager:
		pollution_manager.add_pollution(-pollution_manager.get_pollution())  # Reset a 0

func actualizar_cronometro():
	var tiempo_actual = (Time.get_ticks_msec() - tiempo_inicio) / 1000.0
	Timer_label.text = "Tiempo: %.2fs" % tiempo_actual

func finalizar_carrera():
	tiempo_final = (Time.get_ticks_msec() - tiempo_inicio) / 1000.0
	carrera_en_curso = false
	Timer_label.text = "Final: %.2fs" % tiempo_final
	print("🏁 ¡Carrera completada en %.2fs!" % tiempo_final)
	
	# Obtener contaminación final
	var polucion_final = pollution_manager.get_pollution() if pollution_manager else 0.0
	
	# Guardar resultados
	Global.save_best_times( tiempo_final, pollution_manager.get_pollution(), 0, 0)
	player_movement.set_enable(false)
	camara_movement.set_enable(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	end_screen.show_results()

func actualizar_contador():
	Labcounter_label.text = "Vueltas: %d/%d" % [vueltas_completadas, max_vueltas]
	
func _reset_carrera():
	# Reinicia la escena actual para reiniciar la carrera
	get_tree().reload_current_scene()

func _go_back_to_main_menu():
	# Cambia a la escena principal del menú
	get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
