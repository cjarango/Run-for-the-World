extends WorldEnvironment

## Dependencia inyectada del manager de contaminación
@export var pollution_manager: IPollutionManager

@onready var pollution_bar: ProgressBar = get_node("/root/Main/CanvasLayer/PollutionBar")

# Variables de control
var color_progress: float = 0.0
var fog_progress: float = 0.0
var pollution: float = 0.0
var current_bg_color: Color = Color(1.0, 0.98, 0.96)
var force_bg_color: bool = true  # Bandera para forzar color

# Paleta de colores
const PURE_WHITE := Color(1.0, 0.98, 0.96)
const WARM_YELLOW := Color(0.96, 0.91, 0.72)
const FAINT_HAZE := Color(0.96, 0.96, 0.94)

func _ready():
	reset_environment()
	
	if pollution_manager:
		pollution_manager.pollution_changed.connect(_on_pollution_changed)
	else:
		push_error("No se ha asignado un PollutionManager válido")
	
	# Forzar actualización constante
	set_process(true)

func _process(delta):
	"""Garantiza que el color se mantenga constante cada frame"""
	if force_bg_color:
		self.environment.background_color = current_bg_color

func reset_environment():
	"""Configuración inicial del ambiente"""
	current_bg_color = PURE_WHITE
	self.environment.background_mode = Environment.BG_COLOR
	self.environment.background_color = current_bg_color
	self.environment.fog_enabled = false
	color_progress = 0.0
	fog_progress = 0.0
	force_bg_color = true

func _on_pollution_changed(new_value: float) -> void:
	pollution = clamp(new_value, 0.0, 100.0)
	
	if pollution_bar:
		pollution_bar.value = pollution
	
	_update_progress()
	_apply_effects()

func _update_progress():
	"""Actualización de progresiones"""
	# Color: transición completa al 50%
	color_progress = min(pollution / 50.0, 1.0)
	
	# Niebla: solo aparece después del 50%
	if pollution > 50.0:
		fog_progress = min((pollution - 50.0) / 50.0, 1.0)

func _apply_effects():
	"""Aplicación de efectos visuales"""
	# 1. Actualizar color de fondo (solo si es necesario)
	if pollution <= 50.0:
		current_bg_color = PURE_WHITE.lerp(WARM_YELLOW, color_progress)
	
	# 2. Configurar niebla
	self.environment.fog_enabled = fog_progress > 0.0
	if self.environment.fog_enabled:
		self.environment.fog_light_color = FAINT_HAZE
		self.environment.fog_density = pow(fog_progress, 3) * 0.004
		self.environment.fog_height = 0.0  # Asegurar niebla a nivel del suelo
		self.environment.fog_aerial_perspective = 0.0  # Desactivar efecto atmosférico
		self.environment.fog_light_color = current_bg_color
	
	# 3. Ajustes post-procesado
	self.environment.adjustment_enabled = true
	self.environment.adjustment_brightness = lerp(1.0, 0.95, color_progress + fog_progress*0.3)
	self.environment.adjustment_saturation = lerp(1.0, 0.9, color_progress)
	
	# 4. Forzar actualización
	self.environment.background_color = current_bg_color
