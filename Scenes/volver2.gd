extends Button

func execute() -> void:
	if ResourceLoader.exists("res://Scenes/Menu.tscn"):
		get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
	else:
		push_error("Error: Escena principal no encontrada (res://Scenes/Menu.tscn")
