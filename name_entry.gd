extends Control

@onready var name_input = $LineEdit
@onready var error_label = $ErrorLabel

@export var volver_btn: Button
@export var continuar_btn: Button

func _ready():
	_connect_buttons()
	# Configuración inicial
	error_label.text = ""
	if name_input:
		name_input.grab_focus()  # Enfoca el campo de texto al inicio

func _connect_buttons():
	if continuar_btn:
		if continuar_btn.has_method("execute"):
			continuar_btn.pressed.connect(_on_continuar_pressed)
		else:
			push_error("El botón Continuar no tiene método execute()")
	
	if volver_btn and volver_btn.has_method("execute"):
		volver_btn.pressed.connect(volver_btn.execute)

func _on_continuar_pressed():
	var name = name_input.text.strip_edges()
	
	if name.is_empty():
		error_label.text = "Por favor, ingresa tu nombre."
		name_input.grab_focus()  # Vuelve a enfocar el campo
		return
	
	# Si pasa las validaciones
	error_label.text = ""
	Global.player_name = name
	continuar_btn.execute()  # Ejecuta la acción del botón

# Función para manejar la tecla Enter
func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER:
			_on_continuar_pressed()
