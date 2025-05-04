extends Area3D

var meta_node  # Referencia al nodo de la meta

func _ready():
	meta_node = get_node("/root/Main/Meta")  # Ajusta la ruta según tu escena
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.name == "CuboPrueba" and body.is_in_group("Player"):
		meta_node.checkpoint_pasado = true  # Marca que el jugador pasó el checkpoint
		print("Checkpoint alcanzado ✅")
