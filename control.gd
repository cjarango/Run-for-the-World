extends Node2D

@onready var logo = $grupo_logo  # TextureRect con tu imagen
@onready var audio_player = $AudioStreamPlayer2D

func _ready():
	# Mostrar logo y reproducir audio
	logo.visible = true
	audio_player.play()
	
	# Esperar 1.5 segundos
	await get_tree().create_timer(3).timeout
	
	# Cambiar a la escena principal (o splash de Godot)
	if ResourceLoader.exists("res://Scenes/Menu.tscn"):
		get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
	else:
		push_error("Error: Escena principal no encontrada (res://Scenes/Menu.tscn")

# func _input(event):
	# Opcional: Saltar con cualquier tecla/clic
	# if event is InputEventKey or event is InputEventMouseButton:
		# get_tree().change_scene_to_file("res://Scenes/main.tscn")
