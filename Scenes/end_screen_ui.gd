extends CanvasLayer

@onready var score_grid := $VBoxContainer/ScoreGrid
@onready var restart_message_label := $VBoxContainer/Label2

func show_results():
	clear_score_table()

	# Cargar y ordenar datos desde Global
	var records = Global.sort_by_score(Global.load_best_times())

	# Agregar encabezados
	var headers = ["Pos", "Nombre", "Tiempo", "Contaminación", "Puntos"]
	for header in headers:
		var label = Label.new()
		label.text = header
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		score_grid.add_child(label)

	# Agregar registros (hasta 10)
	for i in range(min(records.size(), 10)):
		var record = records[i]
		score_grid.add_child(create_label(str(i + 1)))  # Posición
		score_grid.add_child(create_label(record["name"]))
		score_grid.add_child(create_label("%.1f" % record["time"]))
		score_grid.add_child(create_label("%.1f" % record["pollution"]))
		score_grid.add_child(create_label(str(record["score"])))

	# Mostrar mensaje de instrucciones
	restart_message_label.text = "Presiona [R] para reiniciar — [Y] para volver al menú"
	restart_message_label.visible = true

	show()

func create_label(text: String) -> Label:
	var label = Label.new()
	label.text = text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label

func clear_score_table():
	for child in score_grid.get_children():
		child.queue_free()
