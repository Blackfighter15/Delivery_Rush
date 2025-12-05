extends CanvasLayer

# --- 1. REFERENCIA AL LABEL (Ajusta la ruta si tu Label tiene otro nombre) ---
@onready var warning_label =  $Panel/Advertencia
@onready var Dinero = $Panel/Label5/DineroActual
var avanzando_nivel: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mostrar_dinero()
	process_mode = Node.PROCESS_MODE_ALWAYS
	actualizar_estado_boton_moto()
	
	# --- 2. ASEGURAR QUE ESTÉ OCULTO AL INICIO ---
	if warning_label:
		warning_label.visible = false

# --- 3. FUNCIÓN PARA MOSTRAR LA ADVERTENCIA TEMPORALMENTE ---
func mostrar_aviso_dinero() -> void:
	if warning_label:
		warning_label.visible = true
		
		# Esperamos 0.5 segundos sin detener el resto del juego
		await get_tree().create_timer(0.5).timeout
		
		# Verificamos que el label siga existiendo (por si cambiaste de escena rápido)
		if is_instance_valid(warning_label):
			warning_label.visible = false

# ---------------------------------------------------------

func _on_salud_pressed() -> void:
	if Global.game_data["Money"] >= 120:	
		Global.game_data["Money"] -= 120
		Global.game_data["Max_Hearts"]+=1
		Global.game_data["Hearts"]+=1
		avanzar_nivel()
	else:
		# Llama a la función aquí
		mostrar_aviso_dinero()

func _on_velocidad_pressed() -> void:
	if Global.game_data["Money"] >= 80:	
		Global.game_data["Money"] -= 80
		Global.game_data["Base_Speed"] *= 1.1
		Global.game_data["speed"] *= 1.1
		avanzar_nivel()
	else:
		# Llama a la función aquí
		mostrar_aviso_dinero()

func _on_moto_pressed() -> void:
	var indice_actual = Global.game_data["skin_index"]
	var max_skins = Global.SKIN_PATHS.size() - 1
	if Global.game_data["Money"] >= 200:	
		Global.game_data["Money"] -= 200
		if indice_actual < max_skins:
			Global.game_data["skin_index"] += 1
			avanzar_nivel()
			
			print("🏍️ Skin mejorada al nivel: ", Global.game_data["skin_index"])
			actualizar_estado_boton_moto()
		else:
			print("⚠️ Ya tienes la skin máxima.")
	else:
		# Llama a la función aquí
		mostrar_aviso_dinero()
		
func actualizar_estado_boton_moto():
	# Si ya tenemos la última skin, deshabilitamos el botón o le cambiamos el texto
	if has_node("Panel/HBoxContainer/Moto+"): # has_node es más seguro
		var boton_moto = $"Panel/HBoxContainer/Moto+"
		var indice_actual = Global.game_data["skin_index"]
		var max_skins = Global.SKIN_PATHS.size() - 1
		
		if indice_actual >= max_skins:
			boton_moto.disabled = true
			boton_moto.visible = false
			# Si tu botón tiene texto, podrías poner: boton_moto.text = "MÁXIMO"
			
			
func mostrar_dinero() -> void:
	if Dinero:
		# 1. Obtenemos el dinero actual
		var dinero_actual = Global.game_data["Money"]
		
		# 2. Cambiamos el texto del label
		# Usamos str() para convertir el número a texto y poder sumarlo
		Dinero.text = str(dinero_actual)
		
		# Opción alternativa más limpia (usando formato):
		# warning_label.text = "Insuficiente. Tienes: $%d" % dinero_actual

		# 3. Lo mostramos y activamos el temporizador
		Dinero.visible = true

func avanzar_nivel():
	# Si ya estamos avanzando, no hacemos nada
	if avanzando_nivel:
		return
	
	# Activamos el candado
	avanzando_nivel = true
	
	Global.game_data["Level"] += 1
	Global.save_game()
	print("🚀 Iniciando Nivel: ", Global.game_data["Level"])
	
	get_tree().paused = false
	get_tree().reload_current_scene()
	queue_free()

func _on_omitir_pressed() -> void:
	avanzar_nivel()
