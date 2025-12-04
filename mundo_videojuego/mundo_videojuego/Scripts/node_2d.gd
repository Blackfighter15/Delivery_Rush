extends Node2D

@export var total_entregas: int = 10
@export var tiempo_spawn: float = 0.5    # cada cuánto se genera una nueva persona

var entregas_realizadas: int = 0
var spawn_timer: float = 0.0


@export var scroll_speed: float = 120.0
@export var block_width: int = 2000
@export var persona_scene: PackedScene
@export var spawn_chance: float = 0.3
@export var tipos_clientes: Array[ClienteDatos] # Array de tus recursos ClienteDatos

@onready var blocks = [$"Primer Nivel", $"Primer Nivel2"]
var personas_por_bloque = {}

func _ready():
	Global.load_game()
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
			limpiar_personas_del_bloque(block)

 # 🕓 Control del tiempo
	
	# 👥 Generar personas con intervalo
	spawn_timer -= delta
	if spawn_timer <= 0:
		generar_persona_aleatoria()
		spawn_timer = tiempo_spawn  # reiniciar el temporizador

func game_over():
	get_tree().paused = true
	# Cargar y mostrar la escena de game over
	var game_over_scene = preload("res://Escenas/game_over.tscn")
	var game_over_instance = game_over_scene.instantiate()
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
	entregas_realizadas += 1
	print("📦 Entrega realizada: ", entregas_realizadas, "/", total_entregas)
	if entregas_realizadas >= total_entregas:
		game_over()



func generar_personas_para_bloque(block):
	# Buscar todos los Marker2D en este bloque
	var spawn_points = []
	for child in block.get_children():
		if child is Marker2D:
			spawn_points.append(child)
	
	for spawn_point in spawn_points:
		if randf() < spawn_chance:
			var persona = persona_scene.instantiate()
			asignar_tipo_cliente(persona)
			add_child(persona)
			persona.position = spawn_point.global_position
			personas_por_bloque[block].append(persona)

func limpiar_personas_del_bloque(block):
	if block in personas_por_bloque:
		for persona in personas_por_bloque[block]:
			if is_instance_valid(persona):
				persona.queue_free()
		personas_por_bloque[block] = []
