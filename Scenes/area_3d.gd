extends Area3D

@onready var Labcounter_label = get_node("/root/Main/CanvasLayer/Label2")
@onready var Timer_label = get_node("/root/Main/CanvasLayer/Timer")
var vueltas_completadas := -1
var max_vueltas := 3
var checkpoint_pasado := true
var tiempo_inicio := 0.0
var tiempo_final := 0.0
var carrera_en_curso := false

func _ready():
	connect("body_entered", _on_body_entered)
	# Inicia el cronómetro al comenzar el juego
	iniciar_cronometro()

func _process(delta):
	if carrera_en_curso:
		actualizar_cronometro()

func _on_body_entered(body):
	if body.name == "CuboPrueba" and body.is_in_group("Player"):
		if checkpoint_pasado:
			vueltas_completadas += 1
			actualizar_contador()
			checkpoint_pasado = false
			
			if vueltas_completadas >= max_vueltas:
				finalizar_carrera()
			else:
				print("¡Vuelta válida! (" + str(vueltas_completadas) + "/" + str(max_vueltas) + ")")
		else:
			print("¡Trampa detectada!")

func iniciar_cronometro():
	tiempo_inicio = Time.get_ticks_msec()
	carrera_en_curso = true
	Timer_label.text = "Tiempo: 0.00s"

func actualizar_cronometro():
	var tiempo_actual = (Time.get_ticks_msec() - tiempo_inicio) / 1000.0
	Timer_label.text = "Tiempo: %.2fs" % tiempo_actual

func finalizar_carrera():
	tiempo_final = (Time.get_ticks_msec() - tiempo_inicio) / 1000.0
	carrera_en_curso = false
	Timer_label.text = "Final: %.2fs" % tiempo_final
	print("¡Carrera completada en ", tiempo_final, " segundos! 🏁")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func actualizar_contador():
	Labcounter_label.text = "Vueltas: %d/%d" % [vueltas_completadas, max_vueltas]
