extends Control

@export var contrarreloj_btn: Button
@export var multijugador_btn: Button
@export var salir_btn: Button

@onready var background_music = $BackgroundMusic

func _ready():
	_connect_buttons()
	background_music.play()

func _connect_buttons():
	if contrarreloj_btn and contrarreloj_btn.has_method("execute"):
		contrarreloj_btn.pressed.connect(contrarreloj_btn.execute)
	
	if multijugador_btn and multijugador_btn.has_method("execute"):
		multijugador_btn.pressed.connect(multijugador_btn.execute)
	
	if salir_btn and salir_btn.has_method("execute"):
		salir_btn.pressed.connect(salir_btn.execute)

func _process(delta):
	if not background_music.playing:
		background_music.play()
