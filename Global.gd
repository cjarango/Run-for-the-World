extends Node

# Variables de jugadores
var player_name: String = ""
var player2_name: String = ""

const SAVE_PATH := "res://archives/save_data.txt"
const MAX_TIME := 300.0
const MAX_POLLUTION := 100.0

# Guardar datos
func save_best_times(time1: float, pollution1: float, time2: float = INF, pollution2: float = INF) -> void:
	# Validar datos jugador 1
	if player_name.strip_edges() == "" or time1 <= 0 or pollution1 < 0:
		push_error("Datos inválidos para jugador principal")
		return
	
	# Asegurar que existe el directorio
	if not DirAccess.dir_exists_absolute("res://archives/"):
		DirAccess.make_dir_absolute("res://archives/")
	
	# Cargar y agregar nuevos registros
	var records = load_best_times()
	
	records.append({
		"name": player_name.strip_edges(),
		"time": time1,
		"pollution": pollution1,
		"score": calculate_score(time1, pollution1)
	})
	
	if player2_name.strip_edges() != "" and time2 > 0 and pollution2 >= 0:
		records.append({
			"name": player2_name.strip_edges(),
			"time": time2,
			"pollution": pollution2,
			"score": calculate_score(time2, pollution2)
		})
	
	# Guardar top 10
	save_records(sort_by_score(records).slice(0, 10))

# Calcular puntuación (0-100)
func calculate_score(time: float, pollution: float) -> int:
	var time_ratio = 1.0 - min(time / MAX_TIME, 1.0)
	var pollution_ratio = 1.0 - min(pollution / MAX_POLLUTION, 1.0)
	return int(round((pollution_ratio * 60) + (time_ratio * 40)))

# Ordenar por puntuación (mayor primero)
func sort_by_score(records: Array) -> Array:
	for i in range(records.size()):
		for j in range(i + 1, records.size()):
			if records[i]["score"] < records[j]["score"]:
				var temp = records[i]
				records[i] = records[j]
				records[j] = temp
	return records

# Guardar registros en archivo (con EOF garantizado)
func save_records(records: Array) -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("No se pudo crear el archivo en: " + SAVE_PATH)
		return
	
	# Escribir cabecera
	file.store_string("Nombre,Tiempo,Contaminacion,Puntos\n")
	
	# Escribir registros
	for record in records:
		file.store_string("%s,%.1f,%.1f,%d\n" % [
			record["name"],
			record["time"],
			record["pollution"],
			record["score"]
		])
	
	# Asegurar EOF al final
	file.store_string("EOF\n")  # <--- Línea clave añadida
	file.close()

# Cargar registros (con soporte para EOF)
func load_best_times() -> Array:
	var records = []
	
	if not FileAccess.file_exists(SAVE_PATH):
		return records
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return records
	
	# Saltar cabecera
	if not file.eof_reached():
		file.get_line()
	
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line == "" or line == "EOF":  # <--- Detección de EOF
			break
		
		var parts = line.split(",")
		if parts.size() >= 4:
			records.append({
				"name": parts[0],
				"time": float(parts[1]),
				"pollution": float(parts[2]),
				"score": int(parts[3])
			})
	
	file.close()
	return records

# Mostrar tabla
func print_score_table() -> void:
	var records = sort_by_score(load_best_times())
	
	print("\n=== MEJORES PUNTUACIONES ===")
	print("Posición  Nombre          Tiempo  Contaminación  Puntos")
	print("-------------------------------------------------------")
	
	for i in range(records.size()):
		var record = records[i]
		print("%4d      %-12s   %6.1f      %6.1f      %4d" % [
			i + 1,
			record["name"],
			record["time"],
			record["pollution"],
			record["score"]
		])
	
	print("-------------------------------------------------------")
