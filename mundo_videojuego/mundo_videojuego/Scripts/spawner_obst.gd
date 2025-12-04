extends Node2D

@export var obstacle_scene: PackedScene
@export var enemy_scene: PackedScene
@export var lanes: Array = [245, 275, 310, 340]
@export var obstacle_resources: Array[Obstaculosdatos] = []

# --- VARIABLES DE CONFIGURACIÓN ---
@export var base_spawn_interval: float = 2.0

# En lugar de una velocidad total, calcularemos un EXTRA
var current_spawn_interval: float = 2.0
var speed_bonus: float = 0.0
var enemy_chance: float = 0.4 # Probabilidad actual

var timer := 0.0

func _ready():
	randomize()
	calcular_dificultad()

func _process(delta):
	timer += delta
	if timer >= current_spawn_interval:
		timer = 0
		spawn_entity()

func calcular_dificultad():
	# 1. Obtenemos el diccionario directamente desde Global
	var config = Global.get_current_level_config()
	
	# 2. Asignamos los valores
	current_spawn_interval = config["spawn_interval"]
	speed_bonus = config["speed_bonus"]
	enemy_chance = config["enemy_chance"]
	
	var nivel_actual = 1
	print("--- Nivel %d Cargado ---" % nivel_actual)
	print("Spawn: %.2fs | Bonus Vel: +%.0f | Chance Enemigo: %.2f" % [current_spawn_interval, speed_bonus, enemy_chance])
func spawn_entity():
	var entity
	
	# Usamos una variable para recordar la velocidad base original del objeto
	# Esto es útil si no queremos leer la del script instanciado, 
	# pero lo mejor es sumar al que ya trae el objeto.

	if randf() < enemy_chance and enemy_scene:
		entity = enemy_scene.instantiate()
		entity.position = Vector2(-50, lanes.pick_random()) 
		print("👾 Enemigo creado")
	else:
		if obstacle_scene:
			entity = obstacle_scene.instantiate()
			# Aumenté 800 a 1200 para asegurarme que nazca fuera de pantalla (derecha)
			entity.position = Vector2(1200, lanes.pick_random()) 
			print("🟥 Obstáculo creado")

			if obstacle_resources.size() > 0:
				var recurso = obstacle_resources[randi() % obstacle_resources.size()]
				entity.set_data(recurso)

	if entity:
		add_child(entity)
		
		# --- AQUÍ LA MEJORA ---
		if "speed" in entity:
			# Sumamos el bono a la velocidad que el objeto ya trae configurada en su script
			entity.speed += speed_bonus
		else:
			print("⚠ ERROR: La entidad no tiene variable 'speed'")
