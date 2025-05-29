extends Control

@onready var time_attack_button = $Button
@onready var background_music = $BackgroundMusic  # AudioStreamPlayer

func _ready():
	time_attack_button.pressed.connect(on_time_attack_pressed)
	
	background_music.play()

func _process(delta):
	if not background_music.is_playing():
		background_music.play()

func on_time_attack_pressed():
	background_music.stop()
	get_tree().change_scene_to_file("res://Scenes/name_entry.tscn")
