extends Control

@onready var name_input = $LineEdit
@onready var start_button = $Button
@onready var error_label = $ErrorLabel


func _ready():
	start_button.pressed.connect(on_start_pressed)

func on_start_pressed():
	var name = name_input.text.strip_edges()
	if name == "":
		error_label.text = "Por favor, ingresa tu nombre."
	else:
		Global.player_name = name
		error_label.text = ""
		get_tree().change_scene_to_file("res://Scenes/main.tscn")
