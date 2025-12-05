#Main_escene
extends Node2D

@export var total_entregas: int = 10
@export var tiempo_spawn: float = 0.5    # cada cuánto se genera una nueva persona
@export var escena_aviso: PackedScene
@export var grupo_nivel_1: Node2D
@export var grupo_nivel_2: Node2D
@export var grupo_nivel_3: Node2D

var entregas_realizadas: int = 0
var spawn_timer: float = 0.0
var nivel_terminado: bool = false

@export var scroll_speed: float = 120.0
@export var block_width: int = 2000
@export var persona_scene: PackedScene
@export var spawn_chance: float = 0.3
@export var tipos_clientes: Array[ClienteDatos] # Array de tus recursos ClienteDatos

var blocks = []
var personas_por_bloque = {}

func _ready():
	Global.load_game()
	seleccionar_escenario_activo()
	
	if Global.has_signal("objetivo_completado"):
		Global.objetivo_completado.connect(eliminar_clientes_existentes_por_tipo)
	
	mostrar_aviso_temporal()
	spawn_timer = tiempo_spawn
	
	for block in blocks:
		personas_por_bloque[block] = []
		generar_personas_para_bloque(block)

func _process(delta):
	for block in blocks:
		block.position.x -= scroll_speed * delta

		if block in personas_por_bloque:
			for persona in personas_por_bloque[block]:
				if is_instance_valid(persona):
					persona.position.x -= scroll_speed * delta
		if block.position.x <= -block_width:
			var rightmost = blocks[0]
			for b in blocks:
				if b.position.x > rightmost.position.x:
					rightmost = b
			
			block.position.x = rightmost.position.x + block_width
			
			# 1. Borrar personas viejas (ya lo tenías)
			limpiar_personas_del_bloque(block) 
			# 2. Resetear los markers para que puedan usarse de nuevo (NUEVO)
			resetear_markers_del_bloque(block)
			# 3. Opcional: Generar nuevas personas inmediatamente en el bloque nuevo
			generar_personas_para_bloque(block)

 # 🕓 Control del tiempo
	
	# 👥 Generar personas con intervalo
	spawn_timer -= delta
	if spawn_timer <= 0:
		generar_persona_aleatoria()
		spawn_timer = tiempo_spawn  # reiniciar el temporizador
		
		
		
# Esta función se llama automáticamente cuando el Global avisa que una comida se completó
func eliminar_clientes_existentes_por_tipo(tipo_comida_completada: String):
	print("🧹 Objetivo completado. Eliminando clientes restantes de: ", tipo_comida_completada)
	
	# Recorremos todos los bloques registrados
	for block in personas_por_bloque:
		var lista_personas = personas_por_bloque[block]
		
		# Iteramos AL REVÉS (de último a primero) para poder borrar elementos del array 
		# sin causar errores de índice.
		for i in range(lista_personas.size() - 1, -1, -1):
			var persona = lista_personas[i]
			
			# Verificamos si la persona existe y tiene datos
			if is_instance_valid(persona) and persona.datos_cliente:
				
				# ¿Es este cliente del tipo que acabamos de terminar?
				if persona.datos_cliente.tipo_comida == tipo_comida_completada:
					
					# 1. ¡IMPORTANTE! Liberar el marker para que otro cliente pueda usarlo
					if "current_marker" in persona and is_instance_valid(persona.current_marker):
						persona.current_marker.set_meta("ocupado", false)
					
					# 2. Efecto visual opcional (si quieres que desaparezcan suavemente)
					# Si no quieres animación, solo usa queue_free() directo
					# crear_efecto_desaparicion(persona.global_position) 
					
					# 3. Eliminar la persona de la escena
					persona.queue_free()
					
					# 4. Eliminar la referencia del array del bloque
					lista_personas.remove_at(i)
					
					

func seleccionar_escenario_activo():
	# 1. Apagamos visuales y MÚSICA de todos los grupos primero
	if grupo_nivel_1: 
		grupo_nivel_1.visible = false
		controlar_musica(grupo_nivel_1, false) # False = Stop
		
	if grupo_nivel_2: 
		grupo_nivel_2.visible = false
		controlar_musica(grupo_nivel_2, false)
		
	if grupo_nivel_3: 
		grupo_nivel_3.visible = false
		controlar_musica(grupo_nivel_3, false)
	
	var nivel_actual = Global.game_data["Level"]
	var contenedor_activo: Node2D = null

	# Tu lógica matemática original
	var indice_escenario = int((nivel_actual - 1) / 3) % 3

	match indice_escenario:
		0: contenedor_activo = grupo_nivel_1
		1: contenedor_activo = grupo_nivel_2
		2: contenedor_activo = grupo_nivel_3

	# 3. Activamos el elegido y su música
	if contenedor_activo:
		contenedor_activo.visible = true
		blocks = contenedor_activo.get_children()
		
		# --- ENCENDER LA MÚSICA AQUÍ ---
		controlar_musica(contenedor_activo, true) # True = Play
		# -------------------------------
		
		print("🗺️ Escenario cargado: ", contenedor_activo.name)
	else:
		# Fallback por defecto (Nivel 1)
		if grupo_nivel_1:
			grupo_nivel_1.visible = true
			blocks = grupo_nivel_1.get_children()
			controlar_musica(grupo_nivel_1, true)

# --- NUEVA FUNCIÓN AUXILIAR INTELIGENTE ---
func controlar_musica(grupo_padre: Node2D, reproducir: bool):
	# find_child busca adentro del nodo, incluso si está en sub-carpetas (true)
	# "MusicaFondo" debe ser el nombre exacto de tu AudioStreamPlayer
	var audio_player = grupo_padre.find_child("MusicaFondo", true, false)
	
	if audio_player and audio_player is AudioStreamPlayer:
		if reproducir:
			if not audio_player.playing: # Solo dar play si no está sonando ya
				audio_player.play()
		else:
			audio_player.stop()
	else:
		# Este print te ayudará a detectar si escribiste mal el nombre en algún nivel
		if reproducir: 
			print("⚠️ Advertencia: No se encontró 'MusicaFondo' dentro de ", grupo_padre.name)

func mostrar_aviso_temporal():
	get_tree().paused = true
	var aviso = escena_aviso.instantiate()
	
	add_child(aviso)
	
	
	await get_tree().create_timer(3.0).timeout
	
	# 5. Borrar la escena
	if is_instance_valid(aviso):
		aviso.queue_free()
	get_tree().paused = false

func game_over():
	# Doble verificación por seguridad
	if get_tree().paused: 
		return
		
	get_tree().paused = true
	# Cargar y mostrar la escena de game over
	var game_over_scene = preload("res://Escenas/game_over.tscn")
	var game_over_instance = game_over_scene.instantiate()
	
	# Asegúrate de que solo haya UNA instancia de game over
	if not get_tree().root.has_node("GameOverScreen"): # Opcional: dale nombre a tu nodo
		game_over_instance.name = "GameOverScreen"
		get_tree().root.add_child(game_over_instance)
	
func generar_persona_aleatoria():
	# 1. Elegir un bloque al azar
	var block = blocks[randi() % blocks.size()]
	
	# 2. Obtener todos los markers
	var all_spawn_points = block.find_children("*", "Marker2D", true)
	if all_spawn_points.is_empty():
		return

	# 3. Filtrar: Crear una lista SOLO con los markers que no están ocupados
	var spawn_points_libres = []
	for point in all_spawn_points:
		# Verificamos si tiene la meta "ocupado". Si no la tiene o es false, sirve.
		if not point.has_meta("ocupado") or point.get_meta("ocupado") == false:
			spawn_points_libres.append(point)

	# Si después de filtrar no queda ninguno libre, salimos de la función
	if spawn_points_libres.is_empty():
		return 
	
	# 4. Elegir uno de los markers LIBRES
	var spawn_point = spawn_points_libres[randi() % spawn_points_libres.size()]
	
	# 5. MARCAR COMO OCUPADO (Muy importante)
	spawn_point.set_meta("ocupado", true)

	# Instanciar la persona
	var persona = persona_scene.instantiate()
	asignar_tipo_cliente(persona)
	add_child(persona)
	persona.position = spawn_point.global_position
	
	# === PASO EXTRA IMPORTANTE ===
	# Necesitas decirle a la persona cuál es su marker para liberarlo cuando se vaya/muera.
	# Asegúrate de que tu script de 'persona' tenga una variable 'my_spawn_marker'.
	if "current_marker" in persona:
		persona.current_marker = spawn_point
	
	if block not in personas_por_bloque:
		personas_por_bloque[block] = []
	personas_por_bloque[block].append(persona)
	
func asignar_tipo_cliente(persona_instancia):
	if tipos_clientes.is_empty():
		return

	# 1. FILTRADO INTELIGENTE
	# Creamos una lista temporal solo con los tipos que Global dice que necesitamos
	var clientes_necesarios = []
	
	for datos in tipos_clientes:
		# Preguntamos al Global: "¿Necesitamos entregar esto?"
		if Global.es_cliente_necesario(datos.tipo_comida):
			clientes_necesarios.append(datos)
	
	# 2. DECISIÓN
	# Si la lista está vacía, significa que todos los objetivos de ese tipo se cumplieron
	if clientes_necesarios.is_empty():
		print("✅ No se necesitan más clientes por ahora.")
		persona_instancia.queue_free() # Borramos la instancia para no tener "fantasmas"
		return

	# 3. SELECCIÓN
	# Elegimos al azar, pero SOLO de la lista de necesarios
	var datos_aleatorios = clientes_necesarios.pick_random()

	var cliente = persona_instancia as Cliente
	if is_instance_valid(cliente) and datos_aleatorios != null:
		cliente.datos_cliente = datos_aleatorios
		print("👤 Generado cliente de: ", datos_aleatorios.tipo_comida)
	
func registrar_entrega():
	# Si el nivel ya terminó, ignoramos cualquier entrega extra
	if nivel_terminado:
		return

	entregas_realizadas += 1
	print("📦 Entrega realizada: ", entregas_realizadas, "/", total_entregas)
	
	if entregas_realizadas >= total_entregas:
		nivel_terminado = true  # <--- ACTIVAMOS EL CANDADO
		game_over()

func generar_personas_para_bloque(block):
	# Buscar todos los Marker2D en este bloque
	var spawn_points = []
	for child in block.get_children():
		if child is Marker2D:
			spawn_points.append(child)
	
	for spawn_point in spawn_points:
		# Verificamos que no esté ocupado antes de intentar spawnear (por seguridad)
		if spawn_point.has_meta("ocupado") and spawn_point.get_meta("ocupado") == true:
			continue

		if randf() < spawn_chance:
			var persona = persona_scene.instantiate()
			asignar_tipo_cliente(persona)
			add_child(persona)
			persona.position = spawn_point.global_position
			
			# --- CORRECCIÓN CLAVE ---
			# Marcamos el marker como ocupado
			spawn_point.set_meta("ocupado", true)
			
			# Le pasamos la referencia a la persona
			if "current_marker" in persona:
				persona.current_marker = spawn_point
			# ------------------------

			personas_por_bloque[block].append(persona)
			
func resetear_markers_del_bloque(block):
	var markers = block.find_children("*", "Marker2D", true)
	for m in markers:
		m.set_meta("ocupado", false)

func limpiar_personas_del_bloque(block):
	if block in personas_por_bloque:
		for persona in personas_por_bloque[block]:
			if is_instance_valid(persona):
				persona.queue_free()
		personas_por_bloque[block] = []
