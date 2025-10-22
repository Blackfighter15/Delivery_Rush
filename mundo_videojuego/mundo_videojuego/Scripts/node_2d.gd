extends Node2D

@export var total_entregas: int = 10
@export var tiempo_limite: float = 90.0  # segundos
@export var tiempo_spawn: float = 3.0    # cada cuánto se genera una nueva persona

var entregas_realizadas: int = 0
var tiempo_restante: float
var spawn_timer: float = 0.0


@export var scroll_speed: float = 120.0
@export var block_width: int = 2000
@export var persona_scene: PackedScene
@export var spawn_chance: float = 0.3
@export var tipos_clientes: Array[ClienteDatos] # Array de tus recursos ClienteDatos

@onready var blocks = [$"Primer Nivel", $"Primer Nivel2"]
var personas_por_bloque = {}

func _ready():
	tiempo_restante = tiempo_limite
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
	tiempo_restante -= delta
	if tiempo_restante <= 0:
		game_over()
	
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
	# Elegir un bloque al azar
	var block = blocks[randi() % blocks.size()]
	var spawn_points = block.find_children("*", "Marker2D", true)
	if spawn_points.is_empty():
		return
	
	var spawn_point = spawn_points[randi() % spawn_points.size()]
	var persona = persona_scene.instantiate()
	asignar_tipo_cliente(persona)
	add_child(persona)
	persona.position = spawn_point.global_position
	
	if block not in personas_por_bloque:
		personas_por_bloque[block] = []
	personas_por_bloque[block].append(persona)
	
func asignar_tipo_cliente(persona_instancia):
	if tipos_clientes.is_empty():
		return

	# 1. Selecciona un recurso de datos al azar
	var datos_aleatorios = tipos_clientes.pick_random()

	# 2. Obtiene la instancia del cliente *como* la clase Cliente
	#    Esto garantiza que Godot reconozca y pueda acceder a la variable 'datos_cliente'
	#    que está definida en el script Cliente.gd (extends StaticBody2D).
	var cliente = persona_instancia as Cliente 

	if is_instance_valid(cliente) and datos_aleatorios != null:
		# Asigna el recurso a la propiedad del script 'Cliente'
		cliente.datos_cliente = datos_aleatorios
		print("👤 Nuevo cliente generado. Tipo: ", datos_aleatorios.tipo_comida)
	
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
