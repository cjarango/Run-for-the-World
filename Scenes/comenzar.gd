extends Button

@export var target_scene: PackedScene

func execute() -> void:
	if target_scene:
		print("Cambiando a escena: ", target_scene.resource_path)
		get_tree().change_scene_to_packed(target_scene)
	else:
		push_error("No se ha asignado una escena objetivo")
