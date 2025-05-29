extends Node

var player_name: String = ""
var best_time := INF

const SAVE_PATH := "res://archives/save_data.txt"

# Guarda un nuevo tiempo y mantiene solo los 10 mejores
func save_best_times(new_name: String, new_time: float) -> void:
	if new_name.strip_edges() == "":
		push_error("El nombre del jugador está vacío, no se guarda el tiempo.")
		return
	if new_time <= 0:
		push_error("El tiempo no puede ser cero o negativo.")
		return

	var times = load_best_times()

	# Añadir el nuevo tiempo
	times.append({"name": new_name.strip_edges(), "time": new_time})

	# Ordenar por tiempo ascendente (mejor tiempo primero) usando función manual
	times = sort_times_by_time(times)

	# Mantener solo los primeros 10
	if times.size() > 10:
		times = times.slice(0, 10)

	# Guardar en archivo
	save_times_to_file(times)

# Función que ordena el array manualmente (burbuja)
func sort_times_by_time(times: Array) -> Array:
	for i in range(times.size()):
		for j in range(i + 1, times.size()):
			if times[i]["time"] > times[j]["time"]:
				var temp = times[i]
				times[i] = times[j]
				times[j] = temp
	return times

# Cargar los mejores tiempos desde archivo
func load_best_times() -> Array:
	var result := []

	if not FileAccess.file_exists(SAVE_PATH):
		return result

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("No se pudo abrir el archivo para leer mejores tiempos.")
		return result

	# Leer y descartar header
	if not file.eof_reached():
		file.get_line()

	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line == "" or line == "EOF":
			break
		var parts = line.split("|")
		# Formato esperado: pos | username | time (seg)
		if parts.size() >= 3:
			var name = parts[1].strip_edges()
			var time = float(parts[2].strip_edges())
			if time > 0:
				result.append({"name": name, "time": time})

	file.close()
	return result

# Guardar los tiempos ordenados en archivo con header y EOF
func save_times_to_file(times: Array) -> void:
	var dir := DirAccess.open("res://")
	if dir == null:
		push_error("No se pudo acceder al directorio res://")
		return

	if not dir.dir_exists("archives"):
		var err = dir.make_dir("archives")
		if err != OK:
			push_error("No se pudo crear el directorio 'archives'. Error: %d" % err)
			return
		else:
			print("Directorio 'archives' creado")

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("No se pudo abrir el archivo para guardar tiempos.")
		return
	else:
		print("Archivo abierto para escritura correctamente")

	# Escribir header
	file.store_string("|pos| username | time (seg)|\n")

	# Guardar cada entrada con su posición
	for i in range(times.size()):
		var entry = times[i]
		file.store_string("%d| %s | %.2f\n" % [i + 1, entry["name"], entry["time"]])

	# Línea EOF para marcar el final
	file.store_string("EOF\n")

	file.close()
	print("Archivo guardado correctamente con %d entradas." % times.size())
